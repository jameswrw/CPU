//
//  JumpTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct JumpTests {
    @Test func testJMP_Absolute() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.JMP_Absolute.rawValue
        memory[0xFFFD] = 0x34
        memory[0xFFFE] = 0x12
        memory[0x1234] = 0xAD
        memory[0x1235] = 0xFF
        
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1234)
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0xFF)
        #expect(cpu.F == Flags.N.rawValue + Flags.One.rawValue)
        #expect(cpu.readFlag(flag: .N) == true)
    }
    
    @Test func testJMP_Indirect() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }

        memory[0xFFFC] = Opcodes6502.JMP_Indirect.rawValue
        memory[0xFFFD] = 0x34
        memory[0xFFFE] = 0x12
        memory[0x1234] = 0x78
        memory[0x1235] = 0x56
        memory[0x5678] = 0xAD
        memory[0x5679] = 0x42
        
        cpu.runForTicks(5)
        #expect(cpu.PC == 0x5678)
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x42)
        #expect(cpu.F == Flags.One.rawValue)
    }
    
    @Test func testJSR_RTS() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        // Not much space at the rest vector, so:
        // • JMP to 0x1234
        // • JSR to 0x5578
        // • RTS should take us to 0x1237 - i.e. an advance of one from where we jumped from.
        memory[0xFFFC] = Opcodes6502.JMP_Absolute.rawValue
        memory[0xFFFD] = 0x34
        memory[0xFFFE] = 0x12
        memory[0x1234] = Opcodes6502.JSR.rawValue
        memory[0x1235] = 0x78
        memory[0x1236] = 0x56
        memory[0x5678] = Opcodes6502.RTS.rawValue

        // JMP 0x1234
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1234)
        #expect(cpu.SP == 0xFF)

        // JSR 0x5678
        cpu.runForTicks(6)
        #expect(cpu.PC == 0x5678)
        #expect(cpu.SP == 0xFD)

        // RTS
        cpu.runForTicks(6)
        #expect(cpu.PC == 0x1237)
        #expect(cpu.SP == 0xFF)
    }
}

