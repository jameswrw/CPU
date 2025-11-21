//
//  File.swift
//  Swift6502
//
//  Created by James Weatherley on 21/11/2025.
//

import Foundation

internal enum Flags: UInt8 {
    case C = 1      // Carry
    case Z = 2      // Zero
    case I = 4      // Interupt disable
    case D = 8      // Decimal
    case B = 16     // Break flag
    case One = 32   // Always 1
    case V = 64     // oVerflow
    case N = 128    // Negative
}

extension CPU6502 {
    
    internal func setFlag(_ flag: Flags) {
        F |= flag.rawValue
    }
    
    internal func clearFlag(_ flag: Flags) {
        F &= ~flag.rawValue
    }
    
    internal func readFlag(_ flag: Flags) -> Bool {
        F & flag.rawValue != 0
    }
}
