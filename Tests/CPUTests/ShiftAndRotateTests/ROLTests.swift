//
//  ROLTests.swift
//  CPU6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct ROLTests {
    @Test func testROL_Accumulator() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate.
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x01
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x02)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x80
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x01)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x42
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x84)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate.
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[0x11] = 0x21
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x42)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rorate that sets zero and carry flags.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[0x11] = 0x80
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x01)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[0x11] = 0x40
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x80)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xAA
        memory[0xAA] = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate
        cpu.X = 0x0A
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0x04
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x08)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        cpu.X = 0x0A
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0x80
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x01)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        cpu.X = 0x0A
        memory[Int(cpu.resetVector)] = Opcodes6502.ASL_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0x40
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x80)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        cpu.X = 0x0A
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_ZeroPageX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[0x5A] = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xFFFE)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate.
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[Int(cpu.resetVector + 2)] = 0x22
        memory[0x2211] = 0x15
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x2A)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[Int(cpu.resetVector + 2)] = 0x22
        memory[0x2211] = 0x80
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x01)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x11
        memory[Int(cpu.resetVector + 2)] = 0x22
        memory[0x2211] = 0x40
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x80)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x60
        memory[0x6050] = 0x00
        
        cpu.runForTicks(2)
        #expect(memory[0x6050] == 0x00)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate
        cpu.X = 0xAA
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x50
        memory[0x50FA] = 0x04
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x08)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        cpu.X = 0xAA
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x50
        memory[0x50FA] = 0x80
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x01)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        cpu.X = 0xAA
        memory[Int(cpu.resetVector)] = Opcodes6502.ASL_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x50
        memory[0x50FA] = 0x40
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x80)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        cpu.X = 0xAA
        memory[Int(cpu.resetVector)] = Opcodes6502.ROL_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x50
        memory[Int(cpu.resetVector + 2)] = 0x60
        memory[0x60FA] = 0x00
        
        cpu.runForTicks(2)
        #expect(memory[0x60FA] == 0x00)
        #expect(cpu.PC == 0xFFFF)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
}
