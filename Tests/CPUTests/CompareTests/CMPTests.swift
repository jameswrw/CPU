//
//  CMPTests.swift
//  Swift6502
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import Swift6502

struct CMPTests {
    @Test func testCMP_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            memory[0xA000] = Opcodes6502.CMP_Immediate.rawValue
            memory[0xA001] = CompareTestInput.memory
            
            cpu.runForTicks(2)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            memory[0xA000] = Opcodes6502.CMP_ZeroPage.rawValue
            memory[0xA001] = 0x55
            memory[0x55] = CompareTestInput.memory
            
            cpu.runForTicks(3)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.X = 0x10
            memory[0xA000] = Opcodes6502.CMP_ZeroPageX.rawValue
            memory[0xA001] = 0x55
            memory[0x65] = CompareTestInput.memory
            
            cpu.runForTicks(4)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            memory[0xA000] = Opcodes6502.CMP_Absolute.rawValue
            memory[0xA001] = 0x34
            memory[0xA002] = 0x12
            memory[0x1234] = CompareTestInput.memory
            
            cpu.runForTicks(4)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // No page boundary crossed.
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.X = 0x10
            
            memory[0xA000] = Opcodes6502.CMP_AbsoluteX.rawValue
            memory[0xA001] = 0x78
            memory[0xA002] = 0x56
            memory[0x5688] = CompareTestInput.memory
            
            cpu.runForTicks(4)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
        
        // Page boundary crossed.
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.X = 0x10
            memory[0xA000] = Opcodes6502.CMP_AbsoluteX.rawValue
            memory[0xA001] = 0xF0
            memory[0xA002] = 0xA0
            memory[0xA100] = CompareTestInput.memory
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(5)
            #expect(cpu.tickcount - oldTickcount == 5)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // No page boundary crossed.
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.Y = 0x10
            memory[0xA000] = Opcodes6502.CMP_AbsoluteY.rawValue
            memory[0xA001] = 0x73
            memory[0xA002] = 0x19
            memory[0x1983] = CompareTestInput.memory
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(4)
            #expect(cpu.tickcount - oldTickcount == 4)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
        
        // Page boundary crossed.
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.Y = 0x10
            memory[0xA000] = Opcodes6502.CMP_AbsoluteY.rawValue
            memory[0xA001] = 0xF0
            memory[0xA002] = 0x40
            memory[0x4100] = CompareTestInput.memory
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(5)
            #expect(cpu.tickcount - oldTickcount == 5)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_IndirectX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.X = 0x10
            memory[0xA000] = Opcodes6502.CMP_IndirectX.rawValue
            memory[0xA001] = 0x42
            memory[0x52] = 0x73
            memory[0x53] = 0x19
            memory[0x1973] = CompareTestInput.memory
            
            cpu.runForTicks(6)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
    
    @Test func testCMP_IndirectY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // No page boundary crossed.
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.Y = 0x10
            memory[0xA000] = Opcodes6502.CMP_IndirectY.rawValue
            memory[0xA001] = 0x22
            memory[0x22] = 0x04
            memory[0x23] = 0x20
            memory[0x2014] = CompareTestInput.memory
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(5)
            #expect(cpu.tickcount - oldTickcount == 5)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
        
        // Page boundary crossed.
        for (i, CompareTestInput) in compareTestInputs.enumerated() {
            cpu.reset()
            cpu.A = CompareTestInput.registerValue
            cpu.Y = 0x40
            memory[0xA000] = Opcodes6502.CMP_IndirectY.rawValue
            memory[0xA001] = 0x22
            memory[0x22] = 0xF0
            memory[0x23] = 0x30
            memory[0x3130] = CompareTestInput.memory
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(6)
            #expect(cpu.tickcount - oldTickcount == 6)
            testCMP(cpu: cpu, CompareTestOutput: compareTestOutputs[i])
        }
    }
}
