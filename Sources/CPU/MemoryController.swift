//
//  MemoryController.swift
//  Swift6502
//
//  Created by James Weatherley on 21/11/2025.
//

// A grand title, but this is not an MMU.
// It abstracts the memory allowing us to redirect I/O or trap reads and writes to specific locations.

internal struct MemoryController {
    
    init(memory: UnsafeMutablePointer<UInt8>, ioAddresses: Set<UInt16> = []) {
        self.memory = memory
        self.ioAddresses = ioAddresses
    }
    
    let memory: UnsafeMutablePointer<UInt8>

    // Maybe an array of ranges of addresses makes more sense. We'll see.
    let ioAddresses: Set<UInt16>
    
    subscript(index: Int) -> UInt8 {
        get {
            return memory[index]
        }
        set(byte) {
            memory[index] = byte
        }
    }
}
