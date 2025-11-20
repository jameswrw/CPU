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
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x34
        memory[Int(cpu.resetVector + 2)] = 0x12
        memory[0x1234] = Opcodes6502.LDA_Immediate.rawValue
        memory[0x1235] = 0xAA
        
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1234)
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0xAA)
        #expect(cpu.readFlag(.N) == true)
    }
    
    @Test func testJMP_Indirect() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Indirect.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x34
        memory[Int(cpu.resetVector + 2)] = 0x12
        memory[0x1234] = 0x78
        memory[0x1235] = 0x56
        memory[0x5678] = Opcodes6502.LDA_Immediate.rawValue
        memory[0x5679] = 0x42
        
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x5678)
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0x42)
        #expect(cpu.F == Flags.One.rawValue | Flags.I.rawValue)
    }
    
    @Test func testJSR_RTS() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Not much space at the rest vector, so:
        // • JMP to 0x1234
        // • JSR to 0x5578
        // • RTS should take us to 0x1237 - i.e. an advance of one from where we jumped from.
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x34
        memory[Int(cpu.resetVector + 2)] = 0x12
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

