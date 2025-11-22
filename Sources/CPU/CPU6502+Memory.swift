//
//  Swift6502+Memory.swift
//  Swift6502
//
//  Created by James Weatherley on 21/11/2025.
//

import Foundation

extension CPU6502 {
    
    // MARK: Memory fundamentals
    internal enum XEndianness {
        case big
        case little
    }
    
    // Made internal so extensions (e.g. CPU6502+ExecuteUtils.swift) can call it
    internal func writeByte(addr: Int, value: UInt8) {
        memory[addr] = value
    }
    
    internal func readByte(addr: Int) -> UInt8 {
        memory[addr]
    }
    
    internal func writeWord(addr: Int, value: UInt16) {
        
        let hi = (value | 0xFF00) >> 8
        let lo = value & 0x00FF
        
        if endianness == .little {
            memory[addr] = UInt8(lo)
            memory[addr + 1] = UInt8(hi)
        } else {
            memory[addr] = UInt8(hi)
            memory[addr + 1] = UInt8(lo)
        }
    }
    
    internal func readWord(addr: Int) -> UInt16 {
        
        var word: UInt16
        if endianness == .little {
            let lo: UInt8 = memory[addr]
            let hi: UInt8 = memory[addr + 1]
            word = UInt16(lo) | (UInt16(hi) << 8)
        } else {
            let hi: UInt8 = memory[addr]
            let lo: UInt8 = memory[addr + 1]
            word = UInt16(hi) | (UInt16(lo) << 8)
        }
        return word
    }
    
    // MARK: Read memory advancing PC
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

