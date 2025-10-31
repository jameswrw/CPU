import Testing
@testable import CPU

struct CPU6502Tests {
    
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

    @Test func testTSX() async throws {
        let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
        defer { memory.deallocate() }
        
        let cpu = CPU6502(memory: memory)
        #expect(cpu.F == Flags.One.rawValue)
        #expect(cpu.X == 0)
        #expect(cpu.SP == 0xFF)
        
        cpu.X = 0x42
        cpu.memory[0xFFFC] = 0xBA
        
        cpu.runForTicks(2)
        #expect(cpu.X == 0xFF)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == Flags.One.rawValue)
    }
    
    @Test func testTXS() async throws {
        let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
        defer { memory.deallocate() }
        
        let cpu = CPU6502(memory: memory)
        #expect(cpu.A == 0)
        #expect(cpu.F == Flags.One.rawValue)
        #expect(cpu.X == 0)
        #expect(cpu.SP == 0xFF)
        
        cpu.X = 0x42
        cpu.memory[0xFFFC] = 0x9A
        
        cpu.runForTicks(2)
        #expect(cpu.X == 0x42)
        #expect(cpu.SP == 0x42)
        #expect(cpu.F == Flags.One.rawValue)
    }
    
    @Test func testPHA() async throws {
        let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
        defer { memory.deallocate() }
        
        let cpu = CPU6502(memory: memory)
        #expect(cpu.A == 0)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == Flags.One.rawValue)
        
        cpu.A = 0x73
        cpu.memory[0xFFFC] = 0x48
        cpu.memory[0x1FF] = 0x0
        
        cpu.runForTicks(3)
        #expect(cpu.A == 0x73)
        #expect(cpu.SP == 0xFE)
        #expect(cpu.memory[0x1FF] == 0x73)
    }
    
    @Test func testPLA() async throws {
        let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
        defer { memory.deallocate() }
        
        let cpu = CPU6502(memory: memory)
        #expect(cpu.A == 0)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == Flags.One.rawValue)
        
        cpu.SP = 0xFE
        cpu.memory[0xFFFC] = 0x68
        cpu.memory[0x1FF] = 0xFF
        
        cpu.runForTicks(4)
        #expect(cpu.A == 0xFF)
        #expect(cpu.SP == 0xFF)
    }
    
    @Test func testPHP() async throws {
        let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
        defer { memory.deallocate() }
        
        let cpu = CPU6502(memory: memory)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == Flags.One.rawValue)
        
        cpu.memory[0xFFFC] = 0x08
        cpu.memory[0x1FF] = 0x0
        
        cpu.runForTicks(3)
        #expect(cpu.SP == 0xFE)
        #expect(cpu.memory[0x1FF] == Flags.One.rawValue)
    }
    
    @Test func testPLP() async throws {
        let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
        defer { memory.deallocate() }
        
        let cpu = CPU6502(memory: memory)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == Flags.One.rawValue)
        
        cpu.SP = 0xFE
        cpu.memory[0xFFFC] = 0x28
        cpu.memory[0x1FF] = 0xAA
        
        cpu.runForTicks(4)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == 0xAA)
    }
}
