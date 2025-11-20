//
//  CPUBase.swift
//  CPU
//
//  Created by James Weatherley on 28/10/2025.
//

public enum Endianness {
    case big
    case little
}

public class CPU {
    public init(memory: UnsafeMutablePointer<UInt8>) {
        self.memory = memory
    }
    
    internal let endianness = Endianness.little
    internal var tickcount: Int = 0
    internal var memory: UnsafeMutablePointer<UInt8>
    
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
}
