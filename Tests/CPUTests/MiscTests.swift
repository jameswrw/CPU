//
//  MiscTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct MiscTests {
    @Test func testNOP() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.NOP.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.X == 0)
        #expect(cpu.Y == 0)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.F == Flags.One.rawValue)
    }
}
