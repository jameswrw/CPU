import Testing
@testable import CPU

@Test func testLDA_Absolute() async throws {
    // Allocate full 64 KiB for 6502 address space
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    defer { memory.deallocate() }

    let cpu = CPU6502(memory: memory)
    print(cpu.A)
    // Place an opcode at the reset vector (or call reset and set PC accordingly)
    memory[0xFFFC] = 0xAD // LDA Absolute opcode (placeholder; real absolute addressing needs two-byte address operand next)
    memory[0xFFFD] = 42

    cpu.runForTicks(2)
    print(cpu.A)
}
