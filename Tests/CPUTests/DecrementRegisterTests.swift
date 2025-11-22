//
//  DecrementRegisterTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct DecrementRegisterTests {
    @Test func testDEX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[Int(cpu.resetVector)] = Opcodes6502.DEX.rawValue
        cpu.X = 0x64

        cpu.runForTicks(2)
        #expect(cpu.X == 0x63)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.DEX.rawValue
        cpu.X = 0x00

        cpu.runForTicks(2)
        #expect(cpu.X == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.DEX.rawValue
        cpu.X = 0x01

        cpu.runForTicks(2)
        #expect(cpu.X == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testDEY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.Y = 0x64
        memory[Int(cpu.resetVector)] = Opcodes6502.DEY.rawValue

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x63)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.DEY.rawValue
        cpu.Y = 0x00

        cpu.runForTicks(2)
        #expect(cpu.Y == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
        
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.DEY.rawValue
        cpu.Y = 0x01

        cpu.runForTicks(2)
        #expect(cpu.Y == 0x00)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
    }
}
