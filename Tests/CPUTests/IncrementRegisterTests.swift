//
//  IncrementRegisterTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct IncrementRegisterTests {
    @Test func testINX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.INX.rawValue
        cpu.X = 0x64

        cpu.runForTicks(2)
        #expect(cpu.X == 0x65)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.INX.rawValue
        cpu.X = 0xFF

        cpu.runForTicks(2)
        #expect(cpu.X == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.INX.rawValue
        cpu.X = 0x7F

        cpu.runForTicks(2)
        #expect(cpu.X == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
    
    @Test func testINY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.INY.rawValue
        cpu.Y = 0x64

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x65)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.INY.rawValue
        cpu.Y = 0xFF

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.INY.rawValue
        cpu.Y = 0x7F

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x80)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
}
