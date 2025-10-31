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

@Test func testJMP_Absolute() async throws {
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    defer { memory.deallocate() }

    let cpu = CPU6502(memory: memory)
    #expect(cpu.A == 0)
    #expect(cpu.F == Flags.One.rawValue)
    
    memory[0xFFFC] = 0x4C
    memory[0xFFFD] = 0x34
    memory[0xFFFE] = 0x12
    memory[0x1234] = 0xAD
    memory[0x1235] = 0xFF
    
    cpu.runForTicks(3)
    #expect(cpu.PC == 0x1234)
    
    cpu.runForTicks(2)
    #expect(cpu.A == 0xFF)
    #expect(cpu.F == Flags.N.rawValue + Flags.One.rawValue)
    #expect(cpu.readFlag(flag: .N) == true)
}

@Test func testJMP_Indirect() async throws {
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    defer { memory.deallocate() }
    
    let cpu = CPU6502(memory: memory)
    #expect(cpu.A == 0)
    #expect(cpu.F == Flags.One.rawValue)
    
    memory[0xFFFC] = 0x6C
    memory[0xFFFD] = 0x34
    memory[0xFFFE] = 0x12
    memory[0x1234] = 0x78
    memory[0x1235] = 0x56
    memory[0x5678] = 0xAD
    memory[0x5679] = 0x42
    
    cpu.runForTicks(5)
    #expect(cpu.PC == 0x5678)
    
    cpu.runForTicks(2)
    #expect(cpu.A == 0x42)
    #expect(cpu.F == Flags.One.rawValue)
}
