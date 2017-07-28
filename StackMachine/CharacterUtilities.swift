//
//  CharacterUtilities.swift
//  StackMachine
//
//  Created by Kristopher Johnson on 7/24/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import Foundation

/// ASCII codes.
public enum Ascii {
    public static let tab    : UInt8 = 0x09
    public static let lf     : UInt8 = 0x0a
    public static let vt     : UInt8 = 0x0b
    public static let ff     : UInt8 = 0x0c
    public static let cr     : UInt8 = 0x0d
    public static let space  : UInt8 = 0x20
    public static let dquote : UInt8 = 0x022
    public static let minus  : UInt8 = 0x2d
    public static let ch0    : UInt8 = 0x30
    public static let ch9    : UInt8 = 0x39
}

/// - returns: true if character is a printable ASCII character.
public func isPrintable(_ ch: UInt8) -> Bool {
    return 0x20 <= ch && ch <= 0x7e
}

/// - returns: true if character is an ASCII digit.
public func isDigit(_ ch: UInt8) -> Bool {
    switch ch {
    case Ascii.ch0...Ascii.ch9: return true
    default: return false
    }
}

/// - returns: true if character is an ASCII whitespace character.
public func isWhitespace(_ ch: UInt8) -> Bool {
    switch ch {
    case Ascii.space, Ascii.tab...Ascii.cr: return true
    default: return false
    }
}
