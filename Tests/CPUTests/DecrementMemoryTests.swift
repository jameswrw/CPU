//
//  DecrementMemoryTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

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
