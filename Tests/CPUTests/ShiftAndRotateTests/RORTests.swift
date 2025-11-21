//
//  RORTests.swift
//  CPU6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct RORTests {
    @Test func testROR_Accumulator() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right rotate.
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_Accumulator.rawValue
        cpu.A = 0x08
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x04)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right rotate that sets negative and carry flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_Accumulator.rawValue
        cpu.A = 0x01
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == true)
        
        // Right rotate that sets the zero flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_Accumulator.rawValue
        cpu.A = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROR_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right rotate.
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xBB
        memory[0xBB] = 0x42
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x21)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right rotate that sets negative and carry flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xBB
        memory[0xBB] = 0x01
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x80)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == true)
        
        // Right rotate that clears the negative flag.
        cpu.reset()
        cpu.setFlag(.N)
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xBB
        memory[0xBB] = 0xFE
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x7F)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROR_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right shift
        cpu.X = 0x0A
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0x04
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x02)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right rotate that sets negative and carry flags.
        cpu.reset()
        cpu.X = 0x0A
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0x01
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x80)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == true)
        
        // Right rotate that clears the negative flag.
        cpu.reset()
        cpu.X = 0x0A
        cpu.setFlag(.N)
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0xFE
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x7F)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROR_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right rotate.
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[Int(cpu.resetVector + 2)] = 0x22
        memory[0x2211] = 0x08
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x04)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right rotate that sets negative and carry flags.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[Int(cpu.resetVector + 2)] = 0x22
        memory[0x2211] = 0x01
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x80)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == true)
        
        // Right rotate that clears the negative flag.
        cpu.reset()
        cpu.setFlag(.N)
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[Int(cpu.resetVector + 2)] = 0x22
        memory[0x2211] = 0xFE
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x7F)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROR_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate
        cpu.X = 0xAA
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x50
        memory[0x50FA] = 0x04
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x02)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right rotate that sets negative and carry flags.
        cpu.reset()
        cpu.X = 0xAA
        memory[Int(cpu.resetVector)] = Opcodes6502.ROR_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x50
        memory[0x50FA] = 0x01
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x80)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == true)
        
        // Right rotate that clears the negative flag.
        cpu.reset()
        cpu.X = 0xAA
        cpu.setFlag(.N)
        memory[Int(cpu.resetVector)] = Opcodes6502.LSR_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x50
        memory[0x50FA] = 0xFE
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x7F)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
}
