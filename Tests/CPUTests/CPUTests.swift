import Testing
//import CPUMacroDecls
@testable import CPU

@inline(__always)
fileprivate func testCPU(assertInitialState: Bool = true) -> (CPU6502, UnsafeMutablePointer<UInt8>) {
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    let cpu = CPU6502(memory: memory)

    if assertInitialState {
        #expect(cpu.A == 0)
        #expect(cpu.X == 0)
        #expect(cpu.Y == 0)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.PC == 0xFFFC)
        #expect(cpu.F == Flags.One.rawValue)
    }

    return (cpu, memory)
}

struct CPU6502Tests {

    struct LoadTests {
        @Test func testLDA_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
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
    }

    struct JumpTests {
        @Test func testJMP_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
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
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }

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
    }
    
    struct StackTests {
        @Test func testTSX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x42
            cpu.memory[0xFFFC] = 0xBA
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0xFF)
            #expect(cpu.SP == 0xFF)
            #expect(cpu.F == Flags.One.rawValue)
        }
        
        @Test func testTXS() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x42
            cpu.memory[0xFFFC] = 0x9A
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0x42)
            #expect(cpu.SP == 0x42)
            #expect(cpu.F == Flags.One.rawValue)
        }
        
        @Test func testPHA() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x73
            cpu.memory[0xFFFC] = 0x48
            cpu.memory[0x1FF] = 0x0
            
            cpu.runForTicks(3)
            #expect(cpu.A == 0x73)
            #expect(cpu.SP == 0xFE)
            #expect(cpu.memory[0x1FF] == 0x73)
        }
        
        @Test func testPLA() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.SP = 0xFE
            cpu.memory[0xFFFC] = 0x68
            cpu.memory[0x1FF] = 0xFF
            
            cpu.runForTicks(4)
            #expect(cpu.A == 0xFF)
            #expect(cpu.SP == 0xFF)
        }
        
        @Test func testPHP() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0x08
            cpu.memory[0x1FF] = 0x0
            
            cpu.runForTicks(3)
            #expect(cpu.SP == 0xFE)
            #expect(cpu.memory[0x1FF] == Flags.One.rawValue)
        }
        
        @Test func testPLP() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.SP = 0xFE
            cpu.memory[0xFFFC] = 0x28
            cpu.memory[0x1FF] = 0xAA
            
            cpu.runForTicks(4)
            #expect(cpu.SP == 0xFF)
            #expect(cpu.F == 0xAA)
        }
    }
    
    struct TransferTests {
        @Test func testTAX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x64
            cpu.memory[0xFFFC] = 0xAA
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.X == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x00
            cpu.X = 0x12
            cpu.memory[0xFFFC] = 0xAA
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.X == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0xFF
            cpu.memory[0xFFFC] = 0xAA
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0xFF)
            #expect(cpu.X == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
        
        @Test func testTXA() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x64
            cpu.memory[0xFFFC] = 0x8A
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.X == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.X = 0x00
            cpu.A = 0x12
            cpu.memory[0xFFFC] = 0x8A
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.X == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x12
            cpu.X = 0xFF
            cpu.memory[0xFFFC] = 0x8A
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0xFF)
            #expect(cpu.X == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
        
        @Test func testTAY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x64
            cpu.memory[0xFFFC] = 0xA8
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.Y == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x00
            cpu.Y = 0x12
            cpu.memory[0xFFFC] = 0xA8
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.Y == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0xFF
            cpu.memory[0xFFFC] = 0xA8
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0xFF)
            #expect(cpu.Y == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
        
        @Test func testTYA() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.Y = 0x64
            cpu.memory[0xFFFC] = 0x98
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.Y == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.Y = 0x00
            cpu.A = 0x12
            cpu.memory[0xFFFC] = 0x98
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.Y == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x12
            cpu.Y = 0xFF
            cpu.memory[0xFFFC] = 0x98
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0xFF)
            #expect(cpu.Y == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
    }

    struct IncrementTests {
        @Test func testINX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x64
            cpu.memory[0xFFFC] = 0xE8
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0x65)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.X = 0xFF
            cpu.memory[0xFFFC] = 0xE8
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.X = 0x7F
            cpu.memory[0xFFFC] = 0xE8
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
        
        @Test func testINY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.Y = 0x64
            cpu.memory[0xFFFC] = 0xC8
            
            cpu.runForTicks(2)
            #expect(cpu.Y == 0x65)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.Y = 0xFF
            cpu.memory[0xFFFC] = 0xC8
            
            cpu.runForTicks(2)
            #expect(cpu.Y == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.Y = 0x7F
            cpu.memory[0xFFFC] = 0xC8
            
            cpu.runForTicks(2)
            #expect(cpu.Y == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
    }
    
    struct DecrementTests {
        @Test func testDEX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x64
            cpu.memory[0xFFFC] = 0xCA
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0x63)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.X = 0x00
            cpu.memory[0xFFFC] = 0xCA
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            cpu.reset()
            cpu.X = 0x01
            cpu.memory[0xFFFC] = 0xCA
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
        
        @Test func testDEY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.Y = 0x64
            cpu.memory[0xFFFC] = 0x88
            
            cpu.runForTicks(2)
            #expect(cpu.Y == 0x63)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.Y = 0x00
            cpu.memory[0xFFFC] = 0x88
            
            cpu.runForTicks(2)
            #expect(cpu.Y == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            cpu.reset()
            cpu.Y = 0x01
            cpu.memory[0xFFFC] = 0x88
            
            cpu.runForTicks(2)
            #expect(cpu.Y == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
    }
    
    struct FlagTests {
        @Test func testCLC() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0x18
            cpu.setFlag(flag: .C)
            #expect(cpu.readFlag(flag: .C) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .C) == false)
        }
        
        @Test func testCLD() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0xD8
            cpu.setFlag(flag: .D)
            #expect(cpu.readFlag(flag: .D) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .D) == false)
        }
        
        @Test func testCLI() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
        
            cpu.memory[0xFFFC] = 0x58
            cpu.setFlag(flag: .I)
            #expect(cpu.readFlag(flag: .I) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .I) == false)
        }
        
        @Test func testCLV() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0xB8
            cpu.setFlag(flag: .V)
            #expect(cpu.readFlag(flag: .V) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .V) == false)
        }
        
        @Test func testSEC() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0x38
            #expect(cpu.readFlag(flag: .C) == false)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .C) == true)
        }
        
        @Test func testSED() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0xF8
            #expect(cpu.readFlag(flag: .D) == false)

            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .D) == true)
        }
        
        @Test func testSEI() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0x78
            #expect(cpu.readFlag(flag: .I) == false)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .I) == true)

        }
    }
    
    struct MiscTests {
        @Test func testNOP() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.memory[0xFFFC] = 0xEA
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.X == 0)
            #expect(cpu.Y == 0)
            #expect(cpu.SP == 0xFF)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.F == Flags.One.rawValue)
        }
    }
}
