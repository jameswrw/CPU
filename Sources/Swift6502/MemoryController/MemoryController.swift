//
//  MemoryController.swift
//  Swift6502
//
//  Created by James Weatherley on 21/11/2025.
//

// A grand title, but this is not an MMU.
// It abstracts the memory allowing us to redirect I/O or trap reads and writes to specific locations.
//
// Reads and writes do use emulated physical memory to access values. It's off limits to the CPU, so
// should be OK.
//
// The read callback returns an optionl which should be used in preference to memory if valid.
// The write callback has a return value. This will typically bethe value passed in, but it could
// be mangled by the callback, in which case write the mangled value rather than the passed in one.
public typealias IOReadCallback = (_: UInt16) -> UInt8?
public typealias IOWriteCallback = (_: UInt16, _: UInt8) -> UInt8

public struct MemoryController {
    
    internal init(memory: UnsafeMutablePointer<UInt8>, ioAddresses: Set<UInt16> = []) {
        self.memory = memory
        self.ioAddresses = ioAddresses
    }
    
    internal let memory: UnsafeMutablePointer<UInt8>

    // Maybe an array of ranges of addresses makes more sense. We'll see.
    public let ioAddresses: Set<UInt16>
    public var ioReadCallBack: IOReadCallback? = nil
    public var ioWriteCallBack: IOWriteCallback? = nil

    internal subscript(index: Int) -> UInt8 {
        get {
            if ioAddresses.contains(UInt16(index)) {
                let _ = ioReadCallBack?(UInt16(index))
            }
            return memory[index]
        }
        set(byte) {
            if ioAddresses.contains(UInt16(index)) {
                let _ = ioWriteCallBack?(UInt16(index), byte)
            }
            memory[index] = byte
        }
    }
}
