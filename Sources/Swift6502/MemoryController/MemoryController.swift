//
//  MemoryController.swift
//  Swift6502
//
//  Created by James Weatherley on 21/11/2025.
//

// A grand title, but this is not an MMU.
// It abstracts the memory allowing us to redirect I/O or trap reads and writes to specific locations.

public typealias IOCallBack = (_: UInt16) -> Void

public struct MemoryController {
    
    internal init(memory: UnsafeMutablePointer<UInt8>, ioAddresses: Set<UInt16> = []) {
        self.memory = memory
        self.ioAddresses = ioAddresses
    }
    
    internal let memory: UnsafeMutablePointer<UInt8>

    // Maybe an array of ranges of addresses makes more sense. We'll see.
    let ioAddresses: Set<UInt16>
    var ioReadCallBack: IOCallBack? = nil
    var ioWriteCallBack: IOCallBack? = nil

    internal subscript(index: Int) -> UInt8 {
        get {
            if ioAddresses.contains(UInt16(index)) {
                ioReadCallBack?(UInt16(index))
            }
            return memory[index]
        }
        set(byte) {
            if ioAddresses.contains(UInt16(index)) {
                ioWriteCallBack?(UInt16(index))
            }
            memory[index] = byte
        }
    }
}
