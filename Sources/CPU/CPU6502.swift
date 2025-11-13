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
    public var SP: UInt8 = 0xFF
    public var PC: UInt16 = 0xFFFC
    public var A: UInt8 = 0
    public var X: UInt8 = 0
    public var Y: UInt8 = 0
    
    // MARK: Flags
    //
    // Avoiding an OptionSet as that implies struct which implies COW
    // which implies performance issues in this use case.
    //
    // This is unproven - so take a look at OptionSet in the future.

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
    
    // MARK: Memory access
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

    // MARK: Stack push/pop
    public func pushByte(_ byte: UInt8) {
        memory[0x100 + Int(SP)] = byte
        SP &-= 1
    }

    public func popByte() -> UInt8 {
        SP &+= 1
        let byte = memory[0x100 + Int(SP)]
        return byte
    }

    public func pushWord(_ word: UInt16)  {
        let hi = UInt8((word & 0xFF00) >> 8)
        let lo = UInt8(word & 0x00FF)
        pushByte(hi)
        pushByte(lo)
    }

    public func popWord() -> UInt16 {
        let lo = UInt16(popByte())
        let hi = UInt16(popByte())
        return (hi << 8) | lo
    }
}

