//
//  CPU6502.swift
//  CPU
//
//  Created by James Weatherley on 28/10/2025.
//

public enum Flags: UInt8 {
    case C = 1      // Carry
    case Z = 2      // Zero
    case I = 4      // Interupt disable
    case D = 8      // Decimal
    case B = 16     // Mysterious B flag
    case One = 32   // Always 1
    case V = 64     // oVerflow
    case N = 128    // Negative
}

public class CPU6502: CPU {
    
    // Registers.
    public var SP: UInt8 = 0x0
    public var PC: UInt16 = 0xFFFC
    public var A: UInt8 = 0
    public var X: UInt8 = 0
    public var Y: UInt8 = 0
    
    // Flags.
    //
    // Avoiding an OptionSet as that implies struct which implies COW
    // which implies performance issues in this use case.
    public var F: UInt8 = Flags.One.rawValue
    
    public func setFlag(flag: Flags) {
        F |= flag.rawValue
    }
    
    public func clearFlag(flag: Flags) {
        F &= ~flag.rawValue
    }
    
    public func readFlag(flag: Flags) -> Bool {
        F & flag.rawValue != 0
    }
    
    // Execution.
    public func nextByte() -> UInt8 {
        let byte = readByte(addr: Int(PC))
        PC += 1
        return byte
    }
    
    public func nextOpcode() -> Opcodes6502 {
        let byte = readByte(addr: Int(PC))
        PC += 1
        return Opcodes6502(rawValue: byte) ?? .NOP
    }
    
    public func nextWord() -> UInt16 {
        let word = readWord16(addr: Int(PC))
        PC += 2
        return word
    }
}

