import Testing
@testable import CPU

@Test func testLDA_Absolute() async throws {
    // Allocate full 64 KiB for 6502 address space
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    defer { memory.deallocate() }

    let cpu = CPU6502(memory: memory)
    #expect(cpu.A == 0)
    #expect(cpu.F == Flags.One.rawValue)

    // Place an opcode at the reset vector (or call reset and set PC accordingly)
    memory[0xFFFC] = 0xAD
    memory[0xFFFD] = 42

    cpu.runForTicks(2)
    #expect(cpu.A == 42)
    #expect(cpu.F == Flags.One.rawValue)
    #expect(cpu.readFlag(flag: .Z) == false)

    cpu.reset()
    memory[0xFFFC] = 0xAD
    memory[0xFFFD] = 0
    
    cpu.runForTicks(2)
    #expect(cpu.A == 0)
    #expect(cpu.F == Flags.Z.rawValue + Flags.One.rawValue)
    #expect(cpu.readFlag(flag: .Z) == true)
    
    cpu.reset()
    memory[0xFFFC] = 0xAD
    memory[0xFFFD] = 0xFF
    
    cpu.runForTicks(2)
    #expect(cpu.A == 0xFF)
    #expect(cpu.F == Flags.N.rawValue + Flags.One.rawValue)
    #expect(cpu.readFlag(flag: .N) == true)
}
