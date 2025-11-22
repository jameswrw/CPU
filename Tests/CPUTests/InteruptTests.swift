//
//  InteruptTests.swift
//  Swift6502
//
//  Created by James Weatherley on 20/11/2025.
//

import Testing
@testable import Swift6502

struct InteruptTests {
    
    @Test func testRTI() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        let oldFlags = cpu.F
        cpu.F = 0xAA
        cpu.pushWord(0x5678)
        cpu.pushByte(oldFlags)
        memory[0xA000] = Opcodes6502.RTI.rawValue
        
        cpu.runForTicks(6)
        #expect(cpu.F == oldFlags)
        #expect(cpu.PC == 0x5678)
    }
    
    @Test func testBRK() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        memory[0xA000] = Opcodes6502.BRK.rawValue
        memory[Int(cpu.irqVector)] = 0x00
        memory[Int(cpu.irqVector + 1)] = 0x20
        
        cpu.runForTicks(7)
        #expect(cpu.PC == 0x2000)
    }
    
    @Test func testBRK_RTI() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        memory[0xA000] = Opcodes6502.BRK.rawValue
        memory[Int(cpu.irqVector)] = 0x00
        memory[Int(cpu.irqVector + 1)] = 0x20
        memory[0x2000] = Opcodes6502.RTI.rawValue
        
        cpu.runForTicks(7)
        #expect(cpu.PC == 0x2000)
        
        cpu.runForTicks(6)
        #expect(cpu.PC == 0xA002)
    }
}
