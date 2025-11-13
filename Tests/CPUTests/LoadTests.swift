//
//  LoadTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct LoadTests {
    @Test func testLDA_Absolute() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        // Place an opcode at the reset vector (or call reset and set PC accordingly)
        memory[0xFFFC] = Opcodes6502.LDA_Absolute.rawValue
        memory[0xFFFD] = 42
        
        cpu.runForTicks(2)
        #expect(cpu.A == 42)
        #expect(cpu.F == Flags.One.rawValue)
        #expect(cpu.readFlag(flag: .Z) == false)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.LDA_Absolute.rawValue
        memory[0xFFFD] = 0
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.F == Flags.Z.rawValue + Flags.One.rawValue)
        #expect(cpu.readFlag(flag: .Z) == true)
        
        cpu.reset()
        memory[0xFFFC] = Opcodes6502.LDA_Absolute.rawValue
        memory[0xFFFD] = 0xFF
        
        cpu.runForTicks(2)
        #expect(cpu.A == 0xFF)
        #expect(cpu.F == Flags.N.rawValue + Flags.One.rawValue)
        #expect(cpu.readFlag(flag: .N) == true)
    }
}
