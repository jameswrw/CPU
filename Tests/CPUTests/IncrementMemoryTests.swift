//
//  IncrementMemoryTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

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
