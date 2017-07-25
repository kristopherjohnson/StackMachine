//
//  StackMachine.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// A StackMachine is a representation of a simple computer
/// with a data stack and a return stack.
open class StackMachine {
    var stack: [StackCell]
    var stackTop: Int
    let stackLimit: Int

    var returnStack: [StackCell]
    var returnStackTop: Int
    let returnStackLimit: Int

    /// Get copy of current stack contents.
    ///
    /// Elements are ordered from bottom to top.
    public var elements: Array<StackCell> {
        return Array(stack[0..<(stackTop + 1)])
    }

    /// Constructor.
    public init() {
        stackTop = -1
        stackLimit = 128
        stack = Array(repeating: .int(0), count: stackLimit)

        returnStackTop = -1
        returnStackLimit = 128
        returnStack = Array(repeating: .int(0), count: returnStackLimit)
    }

    /// Set stacks to be empty.
    public func reset() {
        stackTop = -1
        returnStackTop = -1
    }

    // MARK:- Stack operations

    /// Push the given value onto the stack.
    ///
    /// ( -- x )
    public func push(_ x: StackCell) throws {
        stackTop += 1
        if stackTop < stackLimit {
            stack[stackTop] = x
        }
        else {
            throw StackMachineError.stackOverflow(
                "push: \(x)")
        }
    }

    /// Return the cell at the top of the stack.
    ///
    /// ( -- )
    public func top() throws -> StackCell {
        if stackTop < 0 {
            throw StackMachineError.stackUnderflow("top")
        }
        return stack[stackTop]
    }

    /// Remove the value at the top of the stack.
    ///
    /// ( x -- )
    public func drop() throws {
        if stackTop >= 0 {
            stackTop -= 1
        }
        else {
            throw StackMachineError.stackUnderflow("drop")
        }
    }

    /// Remove the value at the top of the stack, and return it.
    ///
    /// ( x -- )
    public func pop() throws -> StackCell {
        if stackTop >= 0 {
            let cell = stack[stackTop]
            stackTop -= 1
            return cell
        }
        else {
            throw StackMachineError.stackUnderflow("pop")
        }
    }

    /// Overwrite the value at the top of the stack.
    ///
    /// ( x1 -- x2 )
    public func replaceTop(_ x: StackCell) throws {
        if stackTop >= 0 {
            stack[stackTop] = x
        }
        else {
            throw StackMachineError.stackUnderflow(
                "replaceTop: \(x)")
        }
    }

    /// Duplicate the value at the top of the stack.
    ///
    /// ( x1 -- x1 x1 )
    public func dup() throws {
        if stackTop < 0 {
            throw StackMachineError.stackUnderflow("dup")
        }
        stackTop += 1
        if stackTop >= stackLimit {
            throw StackMachineError.stackOverflow("dup")
        }
        stack[stackTop] = stack[stackTop - 1]
    }

    /// Swap the values at the top of the stack.
    ///
    /// ( x1 x2 -- x2 x1 )
    public func swap() throws {
        if stackTop < 1 {
            throw StackMachineError.stackUnderflow("swap")
        }
        Swift.swap(&stack[stackTop], &stack[stackTop - 1])
    }

    /// Make a copy of the cell beneath the top-of-stack.
    ///
    /// ( x1 x2 -- x1 x2 x1 }
    public func over() throws {
        if stackTop < 1 {
            throw StackMachineError.stackUnderflow("over")
        }
        stackTop += 1
        if stackTop >= stackLimit {
            throw StackMachineError.stackOverflow("over")
        }
        stack[stackTop] = stack[stackTop - 2]
    }

    public func pick() throws {
        if stackTop < 0 {
            throw StackMachineError.stackUnderflow("pick")
        }
        let x = try top()
        switch x {
        case .int(let n):
            let index = stackTop - n
            if index < 0 {
                throw StackMachineError.stackUnderflow("pick")
            }
            try replaceTop(stack[index])
        default:
            throw StackMachineError.intRequired("pick")
        }
    }

    /// Get the number of elements on the stack.
    ///
    /// ( -- n )
    public func depth() throws {
        try push(.int(stackTop + 1))
    }

    /// Add the two integers at the top of the stack, leaving the result.
    ///
    /// ( n1 n2 -- n3 )
    func plus() throws {
        let x2 = try pop()
        let x1 = try top()
        switch (x1, x2) {
        case let (.int(n1), .int(n2)):
            try replaceTop(.int(n1 &+ n2))
        default:
            throw StackMachineError.intRequired("+")
        }
    }

    /// Subtract the top-of-stack integer from the next integer, leaving the result.
    ///
    /// ( n1 n2 -- n3 )
    func minus() throws {
        let x2 = try pop()
        let x1 = try top()
        switch (x1, x2) {
        case let (.int(n1), .int(n2)):
            try replaceTop(.int(n1 &- n2))
        default:
            throw StackMachineError.intRequired("-")
        }
    }

    /// Multiply the two integers at the top of the stack, leaving the result.
    ///
    /// ( n1 n2 -- n3 )
    func star() throws {
        let x2 = try pop()
        let x1 = try top()
        switch (x1, x2) {
        case let (.int(n1), .int(n2)):
            try replaceTop(.int(n1 &* n2))
        default:
            throw StackMachineError.intRequired("*")
        }
    }

    /// Divide the top-of-stack integer into the next integer, leaving the result.
    ///
    /// ( n1 n2 -- n3 )
    func slash() throws {
        let x2 = try pop()
        let x1 = try top()
        switch (x1, x2) {
        case let (.int(n1), .int(n2)):
            if n2 == 0 {
                throw StackMachineError.divideByZero("/")
            }
            try replaceTop(.int(n1 / n2))
        default:
            throw StackMachineError.intRequired("/")
        }
    }

    /// Store cell value at the specified address.
    ///
    /// ( x a-addr -- )
    func store() throws {
        let addr = try pop()
        let x = try pop()
        switch addr {
        case .address(let rawPointer):
            let p = UnsafeMutablePointer<StackCell>(rawPointer)
            p.pointee = x
            break
        default:
            throw StackMachineError.addressRequired("!")
        }
    }

    /// Get cell value at the specified address.
    ///
    /// ( a-addr -- x )
    func fetch() throws {
        let addr = try top()
        switch addr {
        case .address(let rawPointer):
            let p = UnsafeMutablePointer<StackCell>(rawPointer)
            try replaceTop(p.pointee)
        default:
            throw StackMachineError.addressRequired("@")
        }
    }
}

