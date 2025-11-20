//
//  CPU6502.swift
//  CPU
//
//  Created by James Weatherley on 28/10/2025.
//

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

public class CPU6502: CPU {
    
    // MARK: Interupts
    internal var waitingForNMIHandler: Bool = false
    internal var waitingForIRQHandler: Bool = false
    
    // MARK: Registers
    internal var SP: UInt8 = 0xFF     // Top of stack. Base address is 0x100, so 0x1FF -> 0x100 is your stack.
    internal var PC: UInt16 = 0xFFFC  // Reset vector - execution starts here.
    internal var A: UInt8 = 0
    internal var X: UInt8 = 0
    internal var Y: UInt8 = 0
    
    // MARK: Flags
    //
    // Avoiding an OptionSet as that implies struct which implies COW
    // which implies performance issues in this use case.
    //
    // This is unproven - so take a look at OptionSet in the future.

    internal var F: UInt8 = Flags.One.rawValue | Flags.I.rawValue
    
    internal func setFlag(_ flag: Flags) {
        F |= flag.rawValue
    }
    
    internal func clearFlag(_ flag: Flags) {
        F &= ~flag.rawValue
    }
    
    internal func readFlag(_ flag: Flags) -> Bool {
        F & flag.rawValue != 0
    }
    
    // MARK: Vectors
    internal let resetVector = 0xFFFC
    internal let irqVector = 0xFFFE
    internal let nmiVector = 0xFFFA
    
    // MARK: Memory access
    internal func nextByte() -> UInt8 {
        let byte = readByte(addr: Int(PC))
        PC &+= 1
        return byte
    }
    
    internal func nextOpcode() -> Opcodes6502 {
        let byte = readByte(addr: Int(PC))
        PC &+= 1
        guard let opcode = Opcodes6502(rawValue: byte) else {
            assert(false, "Invalid opcode")
            return .NOP
        }
        return opcode
    }

    internal func nextWord() -> UInt16 {
        let word = readWord(addr: Int(PC))
        PC &+= 2
        return word
    }

    // MARK: Stack push/pop
    internal func pushByte(_ byte: UInt8) {
        memory[0x100 + Int(SP)] = byte
        SP &-= 1
    }

    internal func popByte() -> UInt8 {
        SP &+= 1
        let byte = memory[0x100 + Int(SP)]
        return byte
    }

    internal func pushWord(_ word: UInt16)  {
        let hi = UInt8((word & 0xFF00) >> 8)
        let lo = UInt8(word & 0x00FF)
        pushByte(hi)
        pushByte(lo)
    }

    internal func popWord() -> UInt16 {
        let lo = UInt16(popByte())
        let hi = UInt16(popByte())
        return (hi << 8) | lo
    }
}

