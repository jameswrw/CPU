//
//  DecrementRegisterTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct DecrementRegisterTests {
    @Test func testDEX() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.DEX.rawValue
        cpu.X = 0x64

        cpu.runForTicks(2)
        #expect(cpu.X == 0x63)
        #expect(cpu.readFlag(flag: .Z) == false)
        #expect(cpu.readFlag(flag: .N) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.DEX.rawValue
        cpu.X = 0x00

        cpu.runForTicks(2)
        #expect(cpu.X == 0xFF)
        #expect(cpu.readFlag(flag: .Z) == false)
        #expect(cpu.readFlag(flag: .N) == true)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.DEX.rawValue
        cpu.X = 0x01

        cpu.runForTicks(2)
        #expect(cpu.X == 0x00)
        #expect(cpu.readFlag(flag: .Z) == true)
        #expect(cpu.readFlag(flag: .N) == false)
    }
    
    @Test func testDEY() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        cpu.Y = 0x64
        memory[0xFFFC] = Opcodes6502.DEY.rawValue

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x63)
        #expect(cpu.readFlag(flag: .Z) == false)
        #expect(cpu.readFlag(flag: .N) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.DEY.rawValue
        cpu.Y = 0x00

        cpu.runForTicks(2)
        #expect(cpu.Y == 0xFF)
        #expect(cpu.readFlag(flag: .Z) == false)
        #expect(cpu.readFlag(flag: .N) == true)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.DEY.rawValue
        cpu.Y = 0x01

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x00)
        #expect(cpu.readFlag(flag: .Z) == true)
        #expect(cpu.readFlag(flag: .N) == false)
    }
}
