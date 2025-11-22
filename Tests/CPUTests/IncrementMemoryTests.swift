//
//  IncrementMemoryTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct IncrementMemoryTests {
    @Test func testINC_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[0xA000] = Opcodes6502.INC_ZeroPage.rawValue
        memory[0xA001] = 0x42
        memory[0x42] = 0x00
        
        cpu.runForTicks(5)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x42] == 1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_ZeroPage.rawValue
        memory[0xA001] = 0x42
        memory[0x42] = 0x7F

        cpu.runForTicks(5)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x42] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_ZeroPage.rawValue
        memory[0xA001] = 0x42
        memory[0x42] = 0xFF

        cpu.runForTicks(5)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x42] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testINC_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[0xA000] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[0xA001] = 0x70
        cpu.X = 0x03
        memory[0x73] = 0x00
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x73] == 0x1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[0xA001] = 0x70
        cpu.X = 0x03
        memory[0x73] = 0x7F

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x73] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[0xA001] = 0x70
        cpu.X = 0x03
        memory[0x73] = 0xFF

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x73] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        // Increment that checks that (opcode argument + X) wraps around.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_ZeroPageX.rawValue
        memory[0xA001] = 0xFF
        cpu.X = 0x74
        memory[0x73] = 0x00
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA002)
        #expect(memory[0x73] == 0x01)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
    }
    
    @Test func testINC_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[0xA000] = Opcodes6502.INC_Absolute.rawValue
        memory[0xA001] = 0x73
        memory[0xA002] = 0x19
        memory[0x1973] = 0x00
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0x1973] == 1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_Absolute.rawValue
        memory[0xA001] = 0x73
        memory[0xA002] = 0x19
        memory[0x1973] = 0x7F

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0x1973] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_Absolute.rawValue
        memory[0xA001] = 0x73
        memory[0xA002] = 0x19
        memory[0x1973] = 0xFF

        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0x1973] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testINC_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple increment.
        memory[0xA000] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[0xA001] = 0x00
        memory[0xA002] = 0xF0
        cpu.X = 0x0D
        memory[0xF00D] = 0x00
        
        cpu.runForTicks(7)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0xF00D] == 1)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)

        // Increment that sets the N flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[0xA001] = 0x00
        memory[0xA002] = 0xF0
        cpu.X = 0x0D
        memory[0xF00D] = 0x7F

        cpu.runForTicks(7)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0xF00D] == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        // Increment that sets the Z flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[0xA001] = 0x00
        memory[0xA002] = 0xF0
        cpu.X = 0x0D
        memory[0xF00D] = 0xFF

        cpu.runForTicks(7)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0xF00D] == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        // Increment that checks that (opcode argument + X) wraps around.
        cpu.reset()
        memory[0xA000] = Opcodes6502.INC_AbsoluteX.rawValue
        memory[0xA001] = 0xFF
        memory[0xA002] = 0xFF
        cpu.X = 0x12
        memory[0x11] = 0x00
        
        cpu.runForTicks(7)
        #expect(cpu.PC == 0xA003)
        #expect(memory[0x11] == 0x01)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
}
