//
//  Stack.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/25/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// A stack of cells.
///
/// Provides common stack manipulation operations.
public class Stack {
    var cells: [StackCell]
    var topIndex: Int

    /// Get copy of current stack contents.
    ///
    /// Elements are ordered from bottom to top.
    public var elements: Array<StackCell> {
        return Array(cells[0...topIndex])
    }

    /// Initializer
    public init(_ maxDepth: Int = 128) {
        cells = Array(repeating: .int(0), count: maxDepth)
        topIndex = -1
    }

    /// Make the stack empty.
    public func reset() {
        topIndex = -1
    }

    /// Push the given value onto the stack.
    ///
    /// ( -- x )
    public func push(_ x: StackCell) throws {
        topIndex += 1
        if topIndex < cells.count {
            cells[topIndex] = x
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
        if topIndex < 0 {
            throw StackMachineError.stackUnderflow("top")
        }
        return cells[topIndex]
    }

    /// Remove the value at the top of the stack.
    ///
    /// ( x -- )
    public func drop() throws {
        if topIndex >= 0 {
            topIndex -= 1
        }
        else {
            throw StackMachineError.stackUnderflow("drop")
        }
    }

    /// Remove the value at the top of the stack, and return it.
    ///
    /// ( x -- )
    public func pop() throws -> StackCell {
        if topIndex >= 0 {
            let cell = cells[topIndex]
            topIndex -= 1
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
        if topIndex >= 0 {
            cells[topIndex] = x
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
        if topIndex < 0 {
            throw StackMachineError.stackUnderflow("dup")
        }
        topIndex += 1
        if topIndex >= cells.count {
            throw StackMachineError.stackOverflow("dup")
        }
        cells[topIndex] = cells[topIndex - 1]
    }

    /// Swap the values at the top of the stack.
    ///
    /// ( x1 x2 -- x2 x1 )
    public func swap() throws {
        if topIndex < 1 {
            throw StackMachineError.stackUnderflow("swap")
        }
        Swift.swap(&cells[topIndex], &cells[topIndex - 1])
    }

    /// Make a copy of the cell beneath the top-of-stack.
    ///
    /// ( x1 x2 -- x1 x2 x1 }
    public func over() throws {
        if topIndex < 1 {
            throw StackMachineError.stackUnderflow("over")
        }
        topIndex += 1
        if topIndex >= cells.count {
            throw StackMachineError.stackOverflow("over")
        }
        cells[topIndex] = cells[topIndex - 2]
    }

    public func pick() throws {
        if topIndex < 0 {
            throw StackMachineError.stackUnderflow("pick")
        }
        let x = try top()
        switch x {
        case .int(let n):
            let index = topIndex - n
            if index < 0 {
                throw StackMachineError.stackUnderflow("pick")
            }
            try replaceTop(cells[index])
        default:
            throw StackMachineError.intRequired("pick")
        }
    }

    /// Get the number of elements on the stack.
    ///
    /// ( -- n )
    public func depth() throws {
        try push(.int(topIndex + 1))
    }
}
