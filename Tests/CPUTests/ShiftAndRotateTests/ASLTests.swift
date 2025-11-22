//
//  ASLTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct ASLTests {
    @Test func testASL_Accumulator() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left shift.
        memory[0xA000] = Opcodes6502.ASL_Accumulator.rawValue
        cpu.A = 0x01
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x02)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left shift that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ASL_Accumulator.rawValue
        cpu.A = 0x80
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left shift that sets negative flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ASL_Accumulator.rawValue
        cpu.A = 0x42
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x84)
        #expect(cpu.PC == 0xA001)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testASL_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left shift.
        memory[0xA000] = Opcodes6502.ASL_ZeroPage.rawValue
        memory[0xA001] = 0x11
        memory[0x11] = 0x21
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x42)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left shift that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ASL_ZeroPage.rawValue
        memory[0xA001] = 0x11
        memory[0x11] = 0x80
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left shift that sets negative flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ASL_ZeroPage.rawValue
        memory[0xA001] = 0x11
        memory[0x11] = 0x40
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x80)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testASL_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left shift
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.ASL_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x04
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x08)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left shift that sets zero and carry flags.
        cpu.reset()
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.ASL_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x80
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left shift that sets negative flag.
        cpu.reset()
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.ASL_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x40
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x80)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testASL_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left shift.
        memory[0xA000] = Opcodes6502.ASL_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x15
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x2A)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left shift that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ASL_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x80
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left shift that sets negative flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ASL_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x40
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x80)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testASL_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left shift
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.ASL_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x04
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x08)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left shift that sets zero and carry flags.
        cpu.reset()
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.ASL_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x80
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left shift that sets negative flag.
        cpu.reset()
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.ASL_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x40
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x80)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
    }
}
