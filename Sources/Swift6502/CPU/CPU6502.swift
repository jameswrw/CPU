//
//  Swift6502.swift
//  Swift6502
//
//  Created by James Weatherley on 28/10/2025.
//

// CPU6502 has a small public interface, but testing wants to poke around with internals.
// This is an issue because you end up with zillions of concurrency warnings. Fixing them
// would be fine, but you seem to need to write accessors that are *only* used by testing.
// e.g.
//  #expect(cpu.X == 0x12)
//
// This produces errors and you end up needing to write something like:
//  let x = await cpu.X
//  #expect(x == 0x12)
//
// Setting values is worse:
//  cpu.X = 0x34
//
// becomes:
// await cpu.setX(0x34)
//
// Where setX() is *only* used in testing. All other access to X is within the actor,
// so ordinarily setX() is not needed.
//
// Setting memory via MemoryController is peak awful:
//  cpu.memory[0x1234] = 12
//
// becomes:
//  await cpu.setMemory(address: 0x1234, value: 0x42)
//
// Again, the access function is only used by tests, and it results in harder to read code that won't
// be used anywhere else. This seems a waste of time.
//
// The best I came up with for testing is to make this a class before running the tests.
public actor CPU6502 {
    
    public init(memory: MemoryWrapper, ioAddresses: Set<UInt16> = []) {
        self.memory = MemoryController(memory: memory.rawMemory, ioAddresses: ioAddresses)
            
        // Can't call readWord() here.
        let rawMemory = memory.rawMemory
        let startAddressLo = UInt16(rawMemory[resetVector])
        let startAddressHi = UInt16(rawMemory[resetVector + 1]) << 8
        PC = startAddressHi | startAddressLo
    }
    
    internal let endianness = Endianness.little
    internal var tickcount: Int = 0
    
    // MARK: Memory
    public var memory: MemoryController
    
    public func setIOReadCallback(_ ioReadCallback: @escaping IOReadCallback) {
        memory.ioReadCallBack = ioReadCallback
    }
    
    public func setIOWriteCallback(_ ioWriteCallback: @escaping IOWriteCallback) {
        memory.ioWriteCallBack = ioWriteCallback
    }
    
    // MARK: Interrupts
    internal var waitingForNMIHandler: Bool = false
    internal var waitingForIRQHandler: Bool = false
    
    // MARK: Registers
    internal var SP: UInt8 = 0xFF   // Top of stack. Base address is 0x100, so 0x1FF -> 0x100 is your stack.
    internal var PC: UInt16         // Gets initialised to resetVector - execution starts here.
    internal var A: UInt8 = 0
    internal var X: UInt8 = 0
    internal var Y: UInt8 = 0
    internal var F: UInt8 = Flags.One.rawValue | Flags.I.rawValue
    
    // MARK: Vectors
    internal let resetVector = 0xFFFC
    internal let irqVector = 0xFFFE
    internal let nmiVector = 0xFFFA
    
    // MARK: Keyboard helper
    // This is a bit skanky, as the 6502 doesn't have this going on in real life.
    internal var kbdBuffer: [UInt8] = []

    public func isEmpty() -> Bool {
        kbdBuffer.isEmpty
    }
    
    public func removeFirst() -> UInt8 {
        kbdBuffer.removeFirst()
    }
    
    public func enqueueKeys(_ bytes: [UInt8]) {
        kbdBuffer.append(contentsOf: bytes)
    }

    public func enqueueKey(_ byte: UInt8) {
        kbdBuffer.append(byte)
    }
}
