//
//  StackCell.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// An Xt (execution token) is a reference to a function/block
/// that takes no arguments and returns no values, but may throw
/// an error, and may have affects on a machine's stack.
public typealias Xt = () throws -> Void

/// A StackMachine's stacks contain StackCell elements.
public enum StackCell {
    case int(Int)
    case string(String)
    case address(OpaquePointer)
    case xt(Xt)

    static let Zero = StackCell.int(0)
    static let One = StackCell.int(1)
    static let False = StackCell.int(0)
    static let True = StackCell.int(-1)

    static let EmptyString = StackCell.string("")
}

extension StackCell: CustomStringConvertible {
    public var description: String {
        switch self {
        case .int(let n):
            return n.description
        case .string(let s):
            // TODO: escape special characters
            return "\"\(s)\""
        case .address(let p):
            return p.debugDescription
        case .xt(let op):
            // TODO: maybe look up in dictionary?
            return "\(op)"
        }
    }
}
