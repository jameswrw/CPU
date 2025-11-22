//
//  CPYTests.swift
//  Swift6502
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import Swift6502

struct CPYTests {
    @Test func testCPY_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.Y = CompareTestInput.registerValue
            memory[0xA000] = Opcodes6502.CPY_Immediate.rawValue
            memory[0xA001] = CompareTestInput.value
            
            cpu.runForTicks(2)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCPY_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.Y = CompareTestInput.registerValue
            memory[0xA000] = Opcodes6502.CPY_ZeroPage.rawValue
            memory[0xA001] = 0x55
            memory[0x55] = CompareTestInput.value
            
            cpu.runForTicks(3)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCPY_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.Y = CompareTestInput.registerValue
            memory[0xA000] = Opcodes6502.CPY_Absolute.rawValue
            memory[0xA001] = 0x34
            memory[0xA002] = 0x12
            memory[0x1234] = CompareTestInput.value
            
            cpu.runForTicks(4)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
}
