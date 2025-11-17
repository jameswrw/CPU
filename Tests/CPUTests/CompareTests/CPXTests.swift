//
//  CPXTests.swift
//  CPU
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import CPU

struct CPXTests {
    @Test func testCPX_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.X = CompareTestInput.registerValue
            memory[0xFFFC] = Opcodes6502.CPX_Immediate.rawValue
            memory[0xFFFD] = CompareTestInput.value
            
            cpu.runForTicks(2)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCPX_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.X = CompareTestInput.registerValue
            memory[0xFFFC] = Opcodes6502.CPX_ZeroPage.rawValue
            memory[0xFFFD] = 0x55
            memory[0x55] = CompareTestInput.value
            
            cpu.runForTicks(3)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCPX_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.X = CompareTestInput.registerValue
            memory[0xFFFC] = Opcodes6502.CPX_Absolute.rawValue
            memory[0xFFFD] = 0x34
            memory[0xFFFE] = 0x12
            memory[0x1234] = CompareTestInput.value
            
            cpu.runForTicks(4)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
}
