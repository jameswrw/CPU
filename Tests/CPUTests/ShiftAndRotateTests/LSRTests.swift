//
//  LSRests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct LSRTests {
    @Test func testLSR_Accumulator() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right shift.
        memory[0xA000] = Opcodes6502.LSR_Accumulator.rawValue
        cpu.A = 0x08
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x04)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right shift that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.LSR_Accumulator.rawValue
        cpu.A = 0x01
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Right shift can't set the negative flag but it can clear it.
        cpu.reset()
        memory[0xA000] = Opcodes6502.LSR_Accumulator.rawValue
        cpu.A = 0xFF
        cpu.setFlag(.N)
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x7F)
        #expect(cpu.PC == 0xA001)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
    }
    
    @Test func testLSR_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right shift.
        memory[0xA000] = Opcodes6502.LSR_ZeroPage.rawValue
        memory[0xA001] = 0xBB
        memory[0xBB] = 0x42
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x21)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right shift a value of zero. This broke when Carry was set.
        cpu.reset()
        cpu.setFlag(.C)
        memory[0xA000] = Opcodes6502.LSR_ZeroPage.rawValue
        memory[0xA001] = 0xBB
        memory[0xBB] = 0x00
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right shift that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.LSR_ZeroPage.rawValue
        memory[0xA001] = 0xBB
        memory[0xBB] = 0x01
        cpu.setFlag(.N)
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Right shift can't set the negative flag but it can clear it.
        cpu.reset()
        cpu.setFlag(.N)
        memory[0xA000] = Opcodes6502.LSR_ZeroPage.rawValue
        memory[0xA001] = 0xBB
        memory[0xBB] = 0xFF
        
        cpu.runForTicks(5)
        #expect(memory[0xBB] == 0x7F)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
    }
    
    @Test func testLSR_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right shift
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.LSR_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x04
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x02)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right shift that sets zero and carry flags.
        cpu.reset()
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.LSR_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x01
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Right shift can't set the negative flag but it can clear it.
        cpu.reset()
        cpu.X = 0x0A
        cpu.setFlag(.N)
        memory[0xA000] = Opcodes6502.LSR_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0xFF
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x7F)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
    }
    
    @Test func testLSR_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple right shift.
        memory[0xA000] = Opcodes6502.LSR_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x08
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x04)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right shift that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.LSR_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x01
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Right shift can't set the negative flag but it can clear it.
        cpu.reset()
        cpu.setFlag(.N)
        memory[0xA000] = Opcodes6502.LSR_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0xFF
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x7F)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
    }
    
    @Test func testLSR_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left shift
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.LSR_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x04
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x02)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Right shift that sets zero and carry flags.
        cpu.reset()
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.LSR_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x01
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Right shift can't set the negative flag but it can clear it.
        cpu.reset()
        cpu.X = 0xAA
        cpu.setFlag(.N)
        memory[0xA000] = Opcodes6502.LSR_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0xFF
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x7F)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
    }
}
