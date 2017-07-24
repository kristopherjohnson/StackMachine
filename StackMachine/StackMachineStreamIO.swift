//
//  StackMachineStreamIO.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// Protocol for an object that provides I/O operations
/// for StackMachineInterpreter.
public protocol StackMachineStreamIO: NSObjectProtocol {
    /// Write a chunk of output.
    func write(_ s: String) throws

    /// Read a chunk of input.
    ///
    /// This should typically return a full input line.
    ///
    /// - returns: `String` or `nil` if at end of input.
    func read() throws -> String?
}
