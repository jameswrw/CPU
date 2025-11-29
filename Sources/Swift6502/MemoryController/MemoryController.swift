//
//  MemoryController.swift
//  Swift6502
//
//  Created by James Weatherley on 21/11/2025.
//

import Foundation

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

public struct MemoryWrapper: @unchecked Sendable {
    public let rawMemory: UnsafeMutablePointer<UInt8>
    public init(_ rawMemory: UnsafeMutablePointer<UInt8>) { self.rawMemory = rawMemory }
}

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
                let ioByte = ioReadCallBack?(UInt16(index))
                if ioByte != nil { return ioByte! }
            }
            return memory[index]
        }
        set(byte) {
            if ioAddresses.contains(UInt16(index)), let callback = ioWriteCallBack {
                let ioValue = callback(UInt16(index), byte)
                memory[index] = ioValue
            } else {
                memory[index] = byte
            }
        }
    }
    
    internal func blitData(_ data: Data, toAddress: UInt16) {
        let _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            // Guards against going off the end of memory, but offers no more protection than that.
            // Clients should guard against over-writing stuff they care about like ROMs etc.
            memcpy(memory, bytes.baseAddress, 0x10000 - data.count)
        }
    }
    
}
