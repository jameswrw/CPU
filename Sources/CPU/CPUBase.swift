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
    
    public let wordSize: Int = 8
    public let endianness = Endianness.little
    public var tickcount: Int = 0
    internal var memory: UnsafeMutablePointer<UInt8>
    
    public func writeByte(addr: Int, value: UInt8) {
        memory[addr] = value
    }
    
    public func readByte(addr: Int) -> UInt8 {
        memory[addr]
    }
    
    public func writeWord16(addr: Int, value: UInt16) {
        
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
    
    public func readWord16(addr: Int) -> UInt16 {
        
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

