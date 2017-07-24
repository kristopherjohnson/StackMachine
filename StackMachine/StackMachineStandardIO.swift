//
//  StackMachineStandardIO.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

open class StackMachineStandardIO: NSObject {
    /// Shared instance.
    public static var instance = StackMachineStandardIO()
}

extension StackMachineStandardIO: StackMachineStreamIO {
    
    /// Write a chunk of output.
    public func write(_ s: String) throws {
        print(s, terminator: "")
    }

    /// Read a chunk of input.
    ///
    /// This should typically return a full input line.
    ///
    /// - returns: `String` or `nil` if at end of input.
    public func read() throws -> String? {
        return readLine()
    }
}
