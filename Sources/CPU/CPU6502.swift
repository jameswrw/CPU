//
//  CPU6502.swift
//  CPU
//
//  Created by James Weatherley on 28/10/2025.
//

public class CPU6502 {
    
    public init(memory: UnsafeMutablePointer<UInt8>) {
        self.memory = memory
    }
    
    internal let endianness = Endianness.little
    internal var tickcount: Int = 0
    internal var memory: UnsafeMutablePointer<UInt8>
    
    // MARK: Interupts
    internal var waitingForNMIHandler: Bool = false
    internal var waitingForIRQHandler: Bool = false
    
    // MARK: Registers
    internal var SP: UInt8 = 0xFF     // Top of stack. Base address is 0x100, so 0x1FF -> 0x100 is your stack.
    internal var PC: UInt16 = 0xFFFC  // Reset vector - execution starts here.
    internal var A: UInt8 = 0
    internal var X: UInt8 = 0
    internal var Y: UInt8 = 0
    internal var F: UInt8 = Flags.One.rawValue | Flags.I.rawValue
    
    // MARK: Vectors
    internal let resetVector = 0xFFFC
    internal let irqVector = 0xFFFE
    internal let nmiVector = 0xFFFA
}

