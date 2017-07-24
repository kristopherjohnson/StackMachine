//
//  StackMachineError.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Errors that can be thrown by StackMachine or StackMachineInterpreter.
///
/// Each error contains a detail string that gives the
/// name of the operation that raised the error, and
/// maybe the value involved.
public enum StackMachineError: Error {
    case stackUnderflow(String)
    case stackOverflow(String)
    case intRequired(String)
    case stringRequired(String)
    case xtRequired(String)
    case addressRequired(String)
    case undefinedWord(String)
}

extension StackMachineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .stackUnderflow(let detail):
            return "stack underflow: \(detail)"
        case .stackOverflow(let detail):
            return "stack overflow: \(detail)"
        case .intRequired(let detail):
            return "integer required: \(detail)"
        case .stringRequired(let detail):
            return "string required: \(detail)"
        case .xtRequired(let detail):
            return "xt required: \(detail)"
        case .addressRequired(let detail):
            return "address required: \(detail)"
        case .undefinedWord(let detail):
            return "undefined word: \(detail)"
        }
    }
}

extension StackMachineError: CustomStringConvertible {
    public var description: String {
        return errorDescription ?? "StackMachineError"
    }
}
