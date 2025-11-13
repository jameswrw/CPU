import Testing
import Foundation
//import CPUMacroDecls
@testable import CPU

@inline(__always)
fileprivate func testCPU(assertInitialState: Bool = true) -> (CPU6502, UnsafeMutablePointer<UInt8>) {
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    memset(memory, 0xFF, 0x10000) // 0xFF is an invalid opcode, so this should catch some tickcount issues.
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
            memory[0xFFFC] = Opcodes6502.LDA_Absolute.rawValue
            memory[0xFFFD] = 42
            
            cpu.runForTicks(2)
            #expect(cpu.A == 42)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.LDA_Absolute.rawValue
            memory[0xFFFD] = 0
            
            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.F == Flags.Z.rawValue + Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == true)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.LDA_Absolute.rawValue
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
            
            memory[0xFFFC] = Opcodes6502.JMP_Absolute.rawValue
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

            memory[0xFFFC] = Opcodes6502.JMP_Indirect.rawValue
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
        
        @Test func testJSR_RTS() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Not much space at the rest vector, so:
            // • JMP to 0x1234
            // • JSR to 0x5578
            // • RTS should take us to 0x1237 - i.e. an advance of one from where we jumped from.
            memory[0xFFFC] = Opcodes6502.JMP_Absolute.rawValue
            memory[0xFFFD] = 0x34
            memory[0xFFFE] = 0x12
            memory[0x1234] = Opcodes6502.JSR.rawValue
            memory[0x1235] = 0x78
            memory[0x1236] = 0x56
            memory[0x5678] = Opcodes6502.RTS.rawValue

            // JMP 0x1234
            cpu.runForTicks(3)
            #expect(cpu.PC == 0x1234)
            #expect(cpu.SP == 0xFF)

            // JSR 0x5678
            cpu.runForTicks(6)
            #expect(cpu.PC == 0x5678)
            #expect(cpu.SP == 0xFD)

            // RTS
            cpu.runForTicks(6)
            #expect(cpu.PC == 0x1237)
            #expect(cpu.SP == 0xFF)
        }
    }
    
    struct StackTests {
        @Test func testTSX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x42
            memory[0xFFFC] = Opcodes6502.TSX.rawValue
            
            cpu.runForTicks(2)
            #expect(cpu.X == 0xFF)
            #expect(cpu.SP == 0xFF)
            #expect(cpu.F == Flags.One.rawValue)
        }
        
        @Test func testTXS() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x42
            memory[0xFFFC] = Opcodes6502.TXS.rawValue

            cpu.runForTicks(2)
            #expect(cpu.X == 0x42)
            #expect(cpu.SP == 0x42)
            #expect(cpu.F == Flags.One.rawValue)
        }
        
        @Test func testPHA() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x73
            memory[0xFFFC] = Opcodes6502.PHA.rawValue
            memory[0x1FF] = 0x0
            
            cpu.runForTicks(3)
            #expect(cpu.A == 0x73)
            #expect(cpu.SP == 0xFE)
            #expect(memory[0x1FF] == 0x73)
        }
        
        @Test func testPLA() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.SP = 0xFE
            memory[0xFFFC] = Opcodes6502.PLA.rawValue
            memory[0x1FF] = 0xFF
            
            cpu.runForTicks(4)
            #expect(cpu.A == 0xFF)
            #expect(cpu.SP == 0xFF)
        }
        
        @Test func testPHP() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.PHP.rawValue
            memory[0x1FF] = 0x0
            
            cpu.runForTicks(3)
            #expect(cpu.SP == 0xFE)
            #expect(memory[0x1FF] == Flags.One.rawValue)
        }
        
        @Test func testPLP() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.SP = 0xFE
            memory[0xFFFC] = Opcodes6502.PLP.rawValue
            memory[0x1FF] = 0xAA
            
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
            memory[0xFFFC] = Opcodes6502.TAX.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.X == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x00
            cpu.X = 0x12
            memory[0xFFFC] = Opcodes6502.TAX.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.X == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0xFF
            memory[0xFFFC] = Opcodes6502.TAX.rawValue

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
            memory[0xFFFC] = Opcodes6502.TXA.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.X == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.X = 0x00
            cpu.A = 0x12
            memory[0xFFFC] = Opcodes6502.TXA.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.X == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x12
            cpu.X = 0xFF
            memory[0xFFFC] = Opcodes6502.TXA.rawValue

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
            memory[0xFFFC] = Opcodes6502.TAY.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.Y == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x00
            cpu.Y = 0x12
            memory[0xFFFC] = Opcodes6502.TAY.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.Y == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0xFF
            memory[0xFFFC] = Opcodes6502.TAY.rawValue

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
            memory[0xFFFC] = Opcodes6502.TYA.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0x64)
            #expect(cpu.Y == 0x64)
            #expect(cpu.F == Flags.One.rawValue)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.Y = 0x00
            cpu.A = 0x12
            memory[0xFFFC] = Opcodes6502.TYA.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0)
            #expect(cpu.Y == 0)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            cpu.A = 0x12
            cpu.Y = 0xFF
            memory[0xFFFC] = Opcodes6502.TYA.rawValue

            cpu.runForTicks(2)
            #expect(cpu.A == 0xFF)
            #expect(cpu.Y == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
    }

    struct IncrementMemoryTests {
        @Test func testINC_ZeroPage() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple increment.
            memory[0xFFFC] = Opcodes6502.INC_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = 0x0
            
            cpu.runForTicks(5)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x42] == 1)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Increment that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = 0x7F

            cpu.runForTicks(5)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x42] == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Increment that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = 0xFF

            cpu.runForTicks(5)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x42] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
        
        @Test func testINC_ZeroPageX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple increment.
            memory[0xFFFC] = Opcodes6502.INC_ZeroPageX.rawValue
            memory[0xFFFD] = 0x70
            cpu.X = 0x3
            memory[0x73] = 0x0
            
            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 1)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Increment that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_ZeroPageX.rawValue
            memory[0xFFFD] = 0x70
            cpu.X = 0x3
            memory[0x73] = 0x7F

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Increment that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_ZeroPageX.rawValue
            memory[0xFFFD] = 0x70
            cpu.X = 0x3
            memory[0x73] = 0xFF

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            // Increment that checks that (opcode argument + X) wraps around.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_ZeroPageX.rawValue
            memory[0xFFFD] = 0xFF
            cpu.X = 0x74
            memory[0x73] = 0x0
            
            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0x1)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
        }
        
        @Test func testINC_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple increment.
            memory[0xFFFC] = Opcodes6502.INC_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = 0x0
            
            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x1973] == 1)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Increment that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = 0x7F

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x1973] == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Increment that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = 0xFF

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x1973] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
        
        @Test func testINC_AbsoluteX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple increment.
            memory[0xFFFC] = Opcodes6502.INC_AbsoluteX.rawValue
            memory[0xFFFD] = 0x00
            memory[0xFFFE] = 0xF0
            cpu.X = 0xD
            memory[0xF00D] = 0x0
            
            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0xF00D] == 1)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Increment that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_AbsoluteX.rawValue
            memory[0xFFFD] = 0x00
            memory[0xFFFE] = 0xF0
            cpu.X = 0xD
            memory[0xF00D] = 0x7F

            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0xF00D] == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Increment that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_AbsoluteX.rawValue
            memory[0xFFFD] = 0x00
            memory[0xFFFE] = 0xF0
            cpu.X = 0xD
            memory[0xF00D] = 0xFF

            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0xF00D] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            // Increment that checks that (opcode argument + X) wraps around.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INC_AbsoluteX.rawValue
            memory[0xFFFD] = 0xFF
            memory[0xFFFE] = 0xFF
            cpu.X = 0x12
            memory[0x11] = 0x0
            
            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x11] == 0x1)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
        }
    }

    struct IncrementRegisterTests {
        @Test func testINX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.INX.rawValue
            cpu.X = 0x64

            cpu.runForTicks(2)
            #expect(cpu.X == 0x65)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INX.rawValue
            cpu.X = 0xFF

            cpu.runForTicks(2)
            #expect(cpu.X == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INX.rawValue
            cpu.X = 0x7F

            cpu.runForTicks(2)
            #expect(cpu.X == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
        
        @Test func testINY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.INY.rawValue
            cpu.Y = 0x64

            cpu.runForTicks(2)
            #expect(cpu.Y == 0x65)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INY.rawValue
            cpu.Y = 0xFF

            cpu.runForTicks(2)
            #expect(cpu.Y == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.INY.rawValue
            cpu.Y = 0x7F

            cpu.runForTicks(2)
            #expect(cpu.Y == 0x80)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
    }
    
    struct DecrementMemoryTests {
        @Test func testDEC_ZeroPage() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple decrement.
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = 0x0A
            
            cpu.runForTicks(5)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x42] == 0x09)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Decrement that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = 0x88

            cpu.runForTicks(5)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x42] == 0x87)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Decrement that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = 0x01

            cpu.runForTicks(5)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x42] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
        
        @Test func testDEC_ZeroPageX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple decrement.
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPageX.rawValue
            memory[0xFFFD] = 0x70
            cpu.X = 0x3
            memory[0x73] = 0x0A
            
            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0x09)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Decrement that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPageX.rawValue
            memory[0xFFFD] = 0x70
            cpu.X = 0x3
            memory[0x73] = 0x88

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0x87)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Decrement that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPageX.rawValue
            memory[0xFFFD] = 0x70
            cpu.X = 0x3
            memory[0x73] = 0x01

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            // Decrement that checks that (opcode argument + X) wraps around.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_ZeroPageX.rawValue
            memory[0xFFFD] = 0xFF
            cpu.X = 0x74
            memory[0x73] = 0x0
            
            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFE)
            #expect(memory[0x73] == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
        }
        
        @Test func testDEC_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple decrement.
            memory[0xFFFC] = Opcodes6502.DEC_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = 0x0A
            
            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x1973] == 0x09)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Decrement that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = 0x88

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x1973] == 0x87)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Decrement that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = 0x01

            cpu.runForTicks(6)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x1973] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
        
        @Test func testDEC_AbsoluteX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // Simple decrement.
            memory[0xFFFC] = Opcodes6502.DEC_AbsoluteX.rawValue
            memory[0xFFFD] = 0x00
            memory[0xFFFE] = 0xF0
            cpu.X = 0xD
            memory[0xF00D] = 0x66
            
            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0xF00D] == 0x65)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)

            // Decrement that sets the N flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_AbsoluteX.rawValue
            memory[0xFFFD] = 0x00
            memory[0xFFFE] = 0xF0
            cpu.X = 0xD
            memory[0xF00D] = 0x99

            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0xF00D] == 0x98)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            // Decrement that sets the Z flag.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_AbsoluteX.rawValue
            memory[0xFFFD] = 0x00
            memory[0xFFFE] = 0xF0
            cpu.X = 0xD
            memory[0xF00D] = 0x01

            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0xF00D] == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
            
            // Decrement that checks that (opcode argument + X) wraps around.
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEC_AbsoluteX.rawValue
            memory[0xFFFD] = 0xFF
            memory[0xFFFE] = 0xFF
            cpu.X = 0x12
            memory[0x11] = 0x36
            
            cpu.runForTicks(7)
            #expect(cpu.PC == 0xFFFF)
            #expect(memory[0x11] == 0x35)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
        }
    }
    
    struct DecrementRegisterTests {
        @Test func testDEX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.DEX.rawValue
            cpu.X = 0x64

            cpu.runForTicks(2)
            #expect(cpu.X == 0x63)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEX.rawValue
            cpu.X = 0x00

            cpu.runForTicks(2)
            #expect(cpu.X == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEX.rawValue
            cpu.X = 0x01

            cpu.runForTicks(2)
            #expect(cpu.X == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
        
        @Test func testDEY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            cpu.Y = 0x64
            memory[0xFFFC] = Opcodes6502.DEY.rawValue

            cpu.runForTicks(2)
            #expect(cpu.Y == 0x63)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == false)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEY.rawValue
            cpu.Y = 0x00

            cpu.runForTicks(2)
            #expect(cpu.Y == 0xFF)
            #expect(cpu.readFlag(flag: .Z) == false)
            #expect(cpu.readFlag(flag: .N) == true)
            
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.DEY.rawValue
            cpu.Y = 0x01

            cpu.runForTicks(2)
            #expect(cpu.Y == 0x00)
            #expect(cpu.readFlag(flag: .Z) == true)
            #expect(cpu.readFlag(flag: .N) == false)
        }
    }
    
    struct ShiftAndRotateTests {
        struct ASLTests {
            @Test func testASL_Accumulator() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left shift.
                memory[0xFFFC] = Opcodes6502.ASL_Accumulator.rawValue
                cpu.A = 0x1
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x02)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left shift that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ASL_Accumulator.rawValue
                cpu.A = 0x80
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x00)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left shift that sets negative flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ASL_Accumulator.rawValue
                cpu.A = 0x42
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x84)
                #expect(cpu.PC == 0xFFFD)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testASL_ZeroPage() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left shift.
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPage.rawValue
                memory[0xFFFD] = 0x11
                memory[0x11] = 0x21
                
                cpu.runForTicks(5)
                #expect(memory[0x11] == 0x42)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left shift that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPage.rawValue
                memory[0xFFFD] = 0x11
                memory[0x11] = 0x80
                
                cpu.runForTicks(5)
                #expect(memory[0x11] == 0x00)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left shift that sets negative flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPage.rawValue
                memory[0xFFFD] = 0x11
                memory[0x11] = 0x40
                
                cpu.runForTicks(5)
                #expect(memory[0x11] == 0x80)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testASL_ZeroPageX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left shift
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x04
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x08)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left shift that sets zero and carry flags.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x80
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x00)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left shift that sets negative flag.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x40
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x80)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testASL_Absolute() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left shift.
                memory[0xFFFC] = Opcodes6502.ASL_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x15
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x2A)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left shift that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ASL_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x80
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x00)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left shift that sets negative flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ASL_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x40
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x80)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testASL_AbsoluteX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left shift
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ASL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x04
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x08)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left shift that sets zero and carry flags.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ASL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x80
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x00)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left shift that sets negative flag.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ASL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x40
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x80)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
            }
        }
        
        struct ROLTests {
            @Test func testROL_Accumulator() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left rotate.
                memory[0xFFFC] = Opcodes6502.ROL_Accumulator.rawValue
                cpu.A = 0x01
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x02)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets carry flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_Accumulator.rawValue
                cpu.A = 0x80
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x01)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left rotate that sets negative flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_Accumulator.rawValue
                cpu.A = 0x42
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x84)
                #expect(cpu.PC == 0xFFFD)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets zero flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_Accumulator.rawValue
                cpu.A = 0x00
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x00)
                #expect(cpu.PC == 0xFFFD)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROL_ZeroPage() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left rotate.
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPage.rawValue
                memory[0xFFFD] = 0x11
                memory[0x11] = 0x21
                
                cpu.runForTicks(5)
                #expect(memory[0x11] == 0x42)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rorate that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPage.rawValue
                memory[0xFFFD] = 0x11
                memory[0x11] = 0x80
                
                cpu.runForTicks(5)
                #expect(memory[0x11] == 0x01)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left rotate that sets negative flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPage.rawValue
                memory[0xFFFD] = 0x11
                memory[0x11] = 0x40
                
                cpu.runForTicks(5)
                #expect(memory[0x11] == 0x80)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets zero flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPage.rawValue
                memory[0xFFFD] = 0xAA
                memory[0xAA] = 0x00
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x00)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROL_ZeroPageX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left rotate
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x04
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x08)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets carry flag.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x80
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x01)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left rotate that sets negative flag.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ASL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x40
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x80)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets zero flag.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ROL_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x00
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x00)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROL_Absolute() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left rotate.
                memory[0xFFFC] = Opcodes6502.ROL_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x15
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x2A)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets carry flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x80
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x01)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left rotate that sets negative flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x40
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x80)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets zero flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROL_Absolute.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x60
                memory[0x6050] = 0x00
                
                cpu.runForTicks(2)
                #expect(memory[0x6050] == 0x00)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROL_AbsoluteX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left rotate
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ROL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x04
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x08)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets carry flag.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ROL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x80
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x01)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Left rotate that sets negative flag.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ASL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x40
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x80)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Left rotate that sets zero flag.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ROL_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x60
                memory[0x60FA] = 0x00
                
                cpu.runForTicks(2)
                #expect(memory[0x60FA] == 0x00)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
        }
        
        struct LSRTests {
            @Test func testLSR_Accumulator() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right shift.
                memory[0xFFFC] = Opcodes6502.LSR_Accumulator.rawValue
                cpu.A = 0x8
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x04)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right shift that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.LSR_Accumulator.rawValue
                cpu.A = 0x01
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x00)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right shift can't set the negative flag but it can clear it.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.LSR_Accumulator.rawValue
                cpu.A = 0xFF
                cpu.setFlag(flag: .N)
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x7F)
                #expect(cpu.PC == 0xFFFD)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
            }
            
            @Test func testLSR_ZeroPage() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right shift.
                memory[0xFFFC] = Opcodes6502.LSR_ZeroPage.rawValue
                memory[0xFFFD] = 0xBB
                memory[0xBB] = 0x42
                
                cpu.runForTicks(5)
                #expect(memory[0xBB] == 0x21)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right shift that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.LSR_ZeroPage.rawValue
                memory[0xFFFD] = 0xBB
                memory[0xBB] = 0x01
                cpu.setFlag(flag: .N)
                
                cpu.runForTicks(5)
                #expect(memory[0xBB] == 0x00)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right shift can't set the negative flag but it can clear it.
                cpu.reset()
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.LSR_ZeroPage.rawValue
                memory[0xFFFD] = 0xBB
                memory[0xBB] = 0xFF
                
                cpu.runForTicks(5)
                #expect(memory[0xBB] == 0x7F)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
            }
            
            @Test func testLSR_ZeroPageX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right shift
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.LSR_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x04
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x02)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right shift that sets zero and carry flags.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.LSR_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x01
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x00)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right shift can't set the negative flag but it can clear it.
                cpu.reset()
                cpu.X = 0xA
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.LSR_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0xFF
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x7F)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
            }
            
            @Test func testLSR_Absolute() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right shift.
                memory[0xFFFC] = Opcodes6502.LSR_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x08
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x04)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right shift that sets zero and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.LSR_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x01
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x00)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right shift can't set the negative flag but it can clear it.
                cpu.reset()
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.LSR_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0xFF
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x7F)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
            }
            
            @Test func testLSR_AbsoluteX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left shift
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.LSR_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x04
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x02)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right shift that sets zero and carry flags.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.LSR_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x01
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x00)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right shift can't set the negative flag but it can clear it.
                cpu.reset()
                cpu.X = 0xAA
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.LSR_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0xFF
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x7F)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == true)
            }
        }
        
        struct RORTests {
            @Test func testROR_Accumulator() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right rotate.
                memory[0xFFFC] = Opcodes6502.ROR_Accumulator.rawValue
                cpu.A = 0x8
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x04)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right rotate that sets negative and carry flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROR_Accumulator.rawValue
                cpu.A = 0x01
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x80)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right rotate that sets the zero flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROR_Accumulator.rawValue
                cpu.A = 0x00
                
                cpu.runForTicks(2)
                #expect(cpu.A == 0x00)
                #expect(cpu.PC == 0xFFFD)
                #expect(cpu.readFlag(flag: .Z) == true)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROR_ZeroPage() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right rotate.
                memory[0xFFFC] = Opcodes6502.ROR_ZeroPage.rawValue
                memory[0xFFFD] = 0xBB
                memory[0xBB] = 0x42
                
                cpu.runForTicks(5)
                #expect(memory[0xBB] == 0x21)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right rotate that sets negative and carry flag.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROR_ZeroPage.rawValue
                memory[0xFFFD] = 0xBB
                memory[0xBB] = 0x01
                
                cpu.runForTicks(5)
                #expect(memory[0xBB] == 0x80)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right rotate that clears the negative flag.
                cpu.reset()
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.ROR_ZeroPage.rawValue
                memory[0xFFFD] = 0xBB
                memory[0xBB] = 0xFE
                
                cpu.runForTicks(5)
                #expect(memory[0xBB] == 0x7F)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROR_ZeroPageX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right shift
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ROR_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x04
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x02)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right rotate that sets negative and carry flags.
                cpu.reset()
                cpu.X = 0xA
                memory[0xFFFC] = Opcodes6502.ROR_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0x01
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x80)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right rotate that clears the negative flag.
                cpu.reset()
                cpu.X = 0xA
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.ROR_ZeroPageX.rawValue
                memory[0xFFFD] = 0x50
                memory[0x5A] = 0xFE
                
                cpu.runForTicks(6)
                #expect(memory[0x5A] == 0x7F)
                #expect(cpu.PC == 0xFFFE)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROR_Absolute() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple right rotate.
                memory[0xFFFC] = Opcodes6502.ROR_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x08
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x04)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right rotate that sets negative and carry flags.
                cpu.reset()
                memory[0xFFFC] = Opcodes6502.ROR_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0x01
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x80)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right rotate that clears the negative flag.
                cpu.reset()
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.ROR_Absolute.rawValue
                memory[0xFFFD] = 0x11
                memory[0xFFFE] = 0x22
                memory[0x2211] = 0xFE
                
                cpu.runForTicks(6)
                #expect(memory[0x2211] == 0x7F)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
            
            @Test func testROR_AbsoluteX() async throws {
                let (cpu, memory) = testCPU()
                defer { memory.deallocate() }
                
                // Simple left rotate
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ROR_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x04
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x02)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
                
                // Right rotate that sets negative and carry flags.
                cpu.reset()
                cpu.X = 0xAA
                memory[0xFFFC] = Opcodes6502.ROR_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0x01
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x80)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == true)
                #expect(cpu.readFlag(flag: .C) == true)
                
                // Right rotate that clears the negative flag.
                cpu.reset()
                cpu.X = 0xAA
                cpu.setFlag(flag: .N)
                memory[0xFFFC] = Opcodes6502.LSR_AbsoluteX.rawValue
                memory[0xFFFD] = 0x50
                memory[0xFFFE] = 0x50
                memory[0x50FA] = 0xFE
                
                cpu.runForTicks(7)
                #expect(memory[0x50FA] == 0x7F)
                #expect(cpu.PC == 0xFFFF)
                #expect(cpu.readFlag(flag: .Z) == false)
                #expect(cpu.readFlag(flag: .N) == false)
                #expect(cpu.readFlag(flag: .C) == false)
            }
        }
    }

    struct FlagTests {
        @Test func testCLC() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.CLC.rawValue
            cpu.setFlag(flag: .C)
            #expect(cpu.readFlag(flag: .C) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .C) == false)
        }
        
        @Test func testCLD() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.CLD.rawValue
            cpu.setFlag(flag: .D)
            #expect(cpu.readFlag(flag: .D) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .D) == false)
        }
        
        @Test func testCLI() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
        
            memory[0xFFFC] = Opcodes6502.CLI.rawValue
            cpu.setFlag(flag: .I)
            #expect(cpu.readFlag(flag: .I) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .I) == false)
        }
        
        @Test func testCLV() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.CLV.rawValue
            cpu.setFlag(flag: .V)
            #expect(cpu.readFlag(flag: .V) == true)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .V) == false)
        }
        
        @Test func testSEC() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.SEC.rawValue
            #expect(cpu.readFlag(flag: .C) == false)
            
            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .C) == true)
        }
        
        @Test func testSED() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.SED.rawValue
            #expect(cpu.readFlag(flag: .D) == false)

            cpu.runForTicks(2)
            #expect(cpu.PC == 0xFFFD)
            #expect(cpu.readFlag(flag: .D) == true)
        }
        
        @Test func testSEI() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            memory[0xFFFC] = Opcodes6502.SEI.rawValue
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
            
            memory[0xFFFC] = Opcodes6502.NOP.rawValue

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
