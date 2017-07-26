//
//  StackMachineInterpreter.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

class DictionaryEntry {
    let name: String
    let xt: Xt
    let isImmediate: Bool

    init(name: String, xt: @escaping Xt, isImmediate: Bool) {
        self.name = name
        self.xt = xt
        self.isImmediate = isImmediate
    }
}

/// A StackMachineInterpreter is a Forth-like language
/// interpreter that operates on a StackMachine.
open class StackMachineInterpreter
{
    /// Stack machine that this interpreter operates upon.
    let sm: StackMachine

    /// Word definitions.
    var dictionary: [String:DictionaryEntry]

    /// Delegate that provides I/O
    weak var io: StackMachineStreamIO?

    /// Current input buffer.
    var inputBuffer: String.UTF8View

    /// Index of next character to be parsed in the input buffer.
    var inputIndex: String.UTF8View.Index

    public init(ioDelegate: StackMachineStreamIO? = nil) {
        sm = StackMachine()
        dictionary = Dictionary()

        inputBuffer = "".utf8
        inputIndex = inputBuffer.startIndex

        defineWords()

        if ioDelegate == nil {
            self.io = StackMachineStandardIO.instance
        }
        else {
            self.io = ioDelegate
        }
    }

    /// Move the given string into the input buffer and interpret it.
    ///
    /// ( i*x s -- j*x )
    public func interpret(_ text: String) throws {
        inputBuffer = text.utf8
        inputIndex = inputBuffer.startIndex
        try interpretInputBuffer()
    }

    /// Interpret the contents of the input buffer.
    ///
    /// ( i*x s -- j*x )
    public func interpretInputBuffer() throws {
        while inputIndex != inputBuffer.endIndex {
            if let token = try readWord() {
                if let n = toInt(token) {
                    try sm.push(.int(n))
                }
                else {
                    try executeWord(token)
                }
            }
        }
    }

    /// If string is numeric, return integer value.
    ///
    /// - returns: `Int` if `s` is an integer string, or `nil` if not.
    public func toInt(_ s: String) -> Int? {
        if isIntLiteral(s) {
            return Int(s)
        }
        else {
            return nil
        }
    }

    /// Determine whether given string is a valid integer literal.
    ///
    /// - todo: Support non-decimal bases
    public func isIntLiteral(_ s: String) -> Bool {
        let utf8 = s.utf8
        if utf8.count < 1 {
            return false
        }

        var range = utf8.startIndex..<utf8.endIndex
        if utf8.first == Ascii.minus {
            let second = utf8.index(after: utf8.startIndex)
            range = second..<utf8.endIndex
        }

        return !utf8[range].contains { !isDigit($0) }
    }

    /// Read the next word from the input buffer.
    ///
    /// - parameter delimiter: Delimiting character
    public func readWord(delimiter: UInt8 = Ascii.space) throws -> String? {
        let limit = inputBuffer.endIndex

        // Skip initial delimiter characters.
        var begin = inputIndex
        while begin != limit && inputBuffer[begin] == delimiter {
            begin = inputBuffer.index(after: begin)
        }
        if begin == limit {
            return nil
        }

        // Find end delimiter.
        var end = inputBuffer.index(after: begin)
        while end != limit && inputBuffer[end] != delimiter {
            end = inputBuffer.index(after: end)
        }

        inputIndex = end

        let word = String(inputBuffer[begin..<end])
        return word
    }

    // MARK:- Word definitions

    public func definePrimitive(_ name: String, _ xt: @escaping Xt) {
        dictionary[name.lowercased()]
            = DictionaryEntry(name: name, xt: xt, isImmediate: false)
    }

    public func findWord(_ name: String) -> Xt? {
        if let entry = self.dictionary[name.lowercased()] {
            return entry.xt
        }
        return nil
    }

    public func executeWord(_ name: String) throws {
        if let op = findWord(name) {
            try op()
        }
        else {
            throw StackMachineError.undefinedWord(
                "\"\(name)\"")
        }
    }

    /// Add built-in word definitions to the dictionary.
    func defineWords() {
        definePrimitive("depth") { try self.sm.depth() }
        definePrimitive("dup")   { try self.sm.dup() }
        definePrimitive("drop")  { try self.sm.drop() }
        definePrimitive("swap")  { try self.sm.swap() }
        definePrimitive("over")  { try self.sm.over() }

        definePrimitive("+")     { try self.sm.plus() }
        definePrimitive("-")     { try self.sm.minus() }
        definePrimitive("*")     { try self.sm.star() }
        definePrimitive("/")     { try self.sm.slash() }

        definePrimitive("!")     { try self.sm.store() }
        definePrimitive("@")     { try self.sm.fetch() }

        definePrimitive("words",    words)
        definePrimitive(".",        dot)
        definePrimitive(".s",       dotS)
        definePrimitive("cr",       cr)
        definePrimitive("bl",       bl)
        definePrimitive("find",     find)
        definePrimitive("execute",  execute)
        definePrimitive("evaluate", evaluate)
        definePrimitive("quit",     quit)
        definePrimitive("bye",      bye)
    }

    // MARK:- Primitives

    /// Look up the XT for the specified name.
    ///
    /// If found, the stack result is `( xt -1 )`, where `xt`
    /// is the execution token.
    ///
    /// If not found, the result is `( s 0 )`, where `s`
    /// is the name that was passed.
    ///
    /// ( s -- s 0  |  xt 1  |  xt -1 )
    ///
    /// - todo: return 1 instead of -1 if it is an immediate word
    public func find() throws {
        let x = try sm.top()
        switch x {
        case .string(let name):
            if let op = findWord(name) {
                try sm.replaceTop(.xt(op))
                try sm.push(StackCell.True)
            }
            else {
                try sm.push(StackCell.False)
            }
        default:
            throw StackMachineError.stringRequired("find")
        }
    }

    /// Execute the xt at the top of the stack.
    ///
    /// ( i*x xt -- j*x )
    public func execute() throws {
        let xt = try sm.pop()
        switch xt {
        case let .xt(op):
            try op()
        default:
            throw StackMachineError.xtRequired("execute")
        }
    }

    /// Print the top-of-stack value, and drop it.
    ///
    /// ( x -- )
    public func dot() throws {
        let x = try sm.pop()
        try io?.write("\(x) ")
    }

    /// Copy and display the values currently on the data stack.
    ///
    /// ( -- )
    public func dotS() throws {
        let elements = sm.elements
        try io?.write("<\(elements.count)> ")
        for x in sm.elements {
            try io?.write("\(x) ")
        }
    }

    /// Push the ASCII code for Space (0x20) to the top of the stack.
    ///
    /// ( -- n )
    public func bl() throws {
        try sm.push(.int(Int(Ascii.space)))
    }

    /// Send end-of-line to output.
    ///
    /// ( -- )
    public func cr() throws {
        try io?.write("\n")
    }

    /// List the definition names.
    ///
    /// ( -- )
    public func words() throws {
        for word in dictionary.keys.sorted() {
            try io?.write("\(word) ")
        }
    }

    /// Make the given string the input buffer and interpret it.
    ///
    /// ( i*x s -- j*x )
    public func evaluate() throws {
        let x = try sm.pop()
        switch x {
        case .string(let s):
            try interpret(s)
        default:
            throw StackMachineError.stringRequired("evaluate")
        }
    }

    /// Accept and interpret input lines.
    ///
    /// ( i**x -- j**x )
    public func quit() throws {
        var wantToExit = false
        repeat {
            do {
                while let input = try io?.read() {
                    try interpret(input)
                    try io?.write(" ok\n")
                }
                wantToExit = true
            }
            catch StackMachineError.bye {
                wantToExit = true
            }
            catch let error as StackMachineError {
                try io?.write("error: \(error)\n")
                sm.reset()
            }
        } while !wantToExit
    }

    /// Return control to the operating system.
    public func bye() throws {
        throw StackMachineError.bye
    }
}
