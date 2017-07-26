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
    /// Data stack.
    var stack: Stack

    /// Return stack.
    var rstack: Stack

    /// Get copy of current stack contents.
    ///
    /// Elements are ordered from bottom to top.
    public var elements: Array<StackCell> {
        return stack.elements
    }

    /// Constructor.
    public init() {
        stack = Stack()
        rstack = Stack()
    }

    /// Set stacks to be empty.
    public func reset() {
        stack.reset()
        rstack.reset()
    }

    // MARK:- Stack operations

    /// Push the given value onto the stack.
    ///
    /// ( -- x )
    public func push(_ x: StackCell) throws {
        try stack.push(x)
    }

    /// Return the cell at the top of the stack.
    ///
    /// ( -- )
    public func top() throws -> StackCell {
        return try stack.top()
    }

    /// Remove the value at the top of the stack.
    ///
    /// ( x -- )
    public func drop() throws {
        try stack.drop()
    }

    /// Remove the value at the top of the stack, and return it.
    ///
    /// ( x -- )
    public func pop() throws -> StackCell {
        return try stack.pop()
    }

    /// Overwrite the value at the top of the stack.
    ///
    /// ( x1 -- x2 )
    public func replaceTop(_ x: StackCell) throws {
        try stack.replaceTop(x)
    }

    /// Duplicate the value at the top of the stack.
    ///
    /// ( x1 -- x1 x1 )
    public func dup() throws {
        try stack.dup()
    }

    /// Swap the values at the top of the stack.
    ///
    /// ( x1 x2 -- x2 x1 )
    public func swap() throws {
        try stack.swap()
    }

    /// Make a copy of the cell beneath the top-of-stack.
    ///
    /// ( x1 x2 -- x1 x2 x1 }
    public func over() throws {
        try stack.over()
    }

    public func pick() throws {
        try stack.pick()
    }

    /// Get the number of elements on the stack.
    ///
    /// ( -- n )
    public func depth() throws {
        try stack.depth()
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
