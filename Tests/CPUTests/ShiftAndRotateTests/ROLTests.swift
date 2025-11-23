//
//  ROLTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct ROLTests {
    @Test func testROL_Accumulator() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate.
        memory[0xA000] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x01
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x02)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag which is initially unset.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x80
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets carry flag which is initially set.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x80
        cpu.setFlag(.C)
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x01)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x42
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x84)
        #expect(cpu.PC == 0xA001)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Accumulator.rawValue
        cpu.A = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xA001)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate.
        memory[0xA000] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[0xA001] = 0x11
        memory[0x11] = 0x21
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x42)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero and carry flags.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[0xA001] = 0x11
        memory[0x11] = 0x80
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[0xA001] = 0x11
        memory[0x11] = 0x40
        
        cpu.runForTicks(5)
        #expect(memory[0x11] == 0x80)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_ZeroPage.rawValue
        memory[0xA001] = 0xAA
        memory[0xAA] = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.ROL_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x04
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x08)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.ROL_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x80
        
        cpu.runForTicks(6)
        #expect(memory[0x5A] == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
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
        
        // Left rotate that sets zero flag.
        cpu.reset()
        cpu.X = 0x0A
        memory[0xA000] = Opcodes6502.ROL_ZeroPageX.rawValue
        memory[0xA001] = 0x50
        memory[0x5A] = 0x00
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x00)
        #expect(cpu.PC == 0xA002)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate.
        memory[0xA000] = Opcodes6502.ROL_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x15
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x2A)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x80
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Absolute.rawValue
        memory[0xA001] = 0x11
        memory[0xA002] = 0x22
        memory[0x2211] = 0x40
        
        cpu.runForTicks(6)
        #expect(memory[0x2211] == 0x80)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets zero flag.
        cpu.reset()
        memory[0xA000] = Opcodes6502.ROL_Absolute.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x60
        memory[0x6050] = 0x00
        
        cpu.runForTicks(2)
        #expect(memory[0x6050] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testROL_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple left rotate
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.ROL_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x04
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x08)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
        
        // Left rotate that sets carry flag.
        cpu.reset()
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.ROL_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x50
        memory[0x50FA] = 0x80
        
        cpu.runForTicks(7)
        #expect(memory[0x50FA] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == true)
        
        // Left rotate that sets negative flag.
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
        
        // Left rotate that sets zero flag.
        cpu.reset()
        cpu.X = 0xAA
        memory[0xA000] = Opcodes6502.ROL_AbsoluteX.rawValue
        memory[0xA001] = 0x50
        memory[0xA002] = 0x60
        memory[0x60FA] = 0x00
        
        cpu.runForTicks(2)
        #expect(memory[0x60FA] == 0x00)
        #expect(cpu.PC == 0xA003)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        #expect(cpu.readFlag(.C) == false)
    }
}
