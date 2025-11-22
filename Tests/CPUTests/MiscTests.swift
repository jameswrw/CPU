//
//  MiscTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct MiscTests {
    @Test func testNOP() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[Int(cpu.resetVector)] = Opcodes6502.NOP.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.X == 0)
        #expect(cpu.Y == 0)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.F == Flags.One.rawValue | Flags.I.rawValue)
    }
}
