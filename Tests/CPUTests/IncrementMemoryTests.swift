//
//  IncrementMemoryTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct IncrementMemoryTests {
    @Test func testINC_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x42
        memory[0x42] = 0x00
        
        cpu.runForTicks(5)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x42] == 1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x42
        memory[0x42] = 0x7F

        cpu.runForTicks(5)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x42] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x42
        memory[0x42] = 0xFF

        cpu.runForTicks(5)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x42] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testINC_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x70
        cpu.X = 0x03
        memory[0x73] = 0x00
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x73] == 0x1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x70
        cpu.X = 0x03
        memory[0x73] = 0x7F

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x73] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x70
        cpu.X = 0x03
        memory[0x73] = 0xFF

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x73] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        // Increment that checks that (opcode argument + X) wraps around.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xFF
        cpu.X = 0x74
        memory[0x73] = 0x00
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFE)
        #expect(memory[0x73] == 0x01)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
    }
    
    @Test func testINC_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x73
        memory[Int(cpu.resetVector + 2)] = 0x19
        memory[0x1973] = 0x00
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0x1973] == 1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x73
        memory[Int(cpu.resetVector + 2)] = 0x19
        memory[0x1973] = 0x7F

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0x1973] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x73
        memory[Int(cpu.resetVector + 2)] = 0x19
        memory[0x1973] = 0xFF

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0x1973] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testINC_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x00
        memory[Int(cpu.resetVector + 2)] = 0xF0
        cpu.X = 0x0D
        memory[0xF00D] = 0x00
        
        cpu.runForTicks(7)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0xF00D] == 1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x00
        memory[Int(cpu.resetVector + 2)] = 0xF0
        cpu.X = 0x0D
        memory[0xF00D] = 0x7F

        cpu.runForTicks(7)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0xF00D] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x00
        memory[Int(cpu.resetVector + 2)] = 0xF0
        cpu.X = 0x0D
        memory[0xF00D] = 0xFF

        cpu.runForTicks(7)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0xF00D] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        // Increment that checks that (opcode argument + X) wraps around.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xFF
        memory[Int(cpu.resetVector + 2)] = 0xFF
        cpu.X = 0x12
        memory[0x11] = 0x00
        
        cpu.runForTicks(7)
        #expect(cpu.PC == 0xFFFF)
        #expect(memory[0x11] == 0x01)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
}
