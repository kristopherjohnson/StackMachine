//
//  StackMachineInterpreter.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// A StackMachineInterpreter is a Forth-like language
/// interpreter that operates on a StackMachine.
open class StackMachineInterpreter
{
    let sm: StackMachine
    var dictionary: [String:Xt]

    weak var ioDelegate: StackMachineStreamIO?

    public init(ioDelegate: StackMachineStreamIO? = nil) {
        sm = StackMachine()
        dictionary = Dictionary()
        defineWords()

        if ioDelegate == nil {
            self.ioDelegate = StackMachineStandardIO.instance
        }
        else {
            self.ioDelegate = ioDelegate
        }
    }

    public func interpret(_ text: String) throws {
        try ioDelegate?.write("INTERPRET: \(text)")
    }

    // MARK:- Word definitions

    public func definePrimitive(_ name: String, _ op: @escaping Xt) {
        dictionary[name.lowercased()] = op
    }

    public func findWord(_ name: String) -> Xt? {
        return self.dictionary[name.lowercased()]
    }

    public func executeWord(_ name: String) throws {
        if let op = findWord(name) {
            try op()
        }
        else {
            throw StackMachineError.undefinedWord(
                "executeWord: \(name)")
        }
    }

    /// Add built-in word definitions to the dictionary.
    public func defineWords() {
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

        definePrimitive("words",   words)
        definePrimitive(".",       dot)
        definePrimitive("cr",      cr)
        definePrimitive("bl",      bl)
        definePrimitive("find",    find)
        definePrimitive("execute", execute)
        definePrimitive("quit",    quit)
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
    func find() throws {
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
    func execute() throws {
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
    func dot() throws {
        let x = try sm.pop()
        print(x)
    }

    /// Push the ASCII code for Space (0x20) to the top of the stack.
    ///
    /// ( -- n )
    func bl() throws {
        try sm.push(.int(0x20))
    }

    /// Send carriage-return to standard output.
    ///
    /// ( -- )
    func cr() throws {
        try ioDelegate?.write("\n")
    }

    /// List the definition names.
    ///
    /// ( -- )
    func words() throws {
        for (name, _) in dictionary {
            try ioDelegate?.write("\(name) ")
        }
        try cr()
    }

    /// Accept and interpret input lines.
    func quit() throws {
        try ioDelegate?.write("sm ok >\n")
        do {
            while let input = try ioDelegate?.read() {
                try interpret(input)
                try ioDelegate?.write("ok >\n")
            }
        }
        catch let error as StackMachineError {
            try ioDelegate?.write("error: \(error)\n")
            // TODO: Clear stacks, etc.
        }
    }
}
