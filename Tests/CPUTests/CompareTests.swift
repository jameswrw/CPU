//
//  CompareTests.swift
//  CPU
//
//  Created by James Weatherley on 14/11/2025.
//

import Testing
@testable import CPU

fileprivate struct TestInput {
    let value: UInt8
    let registerValue: UInt8
}

fileprivate struct TestOutput {
    let C: Bool
    let Z: Bool
    let N: Bool
}

fileprivate let testInputs = [
    TestInput(value: 0x34, registerValue: 0x24),
    TestInput(value: 0x81, registerValue: 0x80),
    TestInput(value: 0x53, registerValue: 0x53),
    TestInput(value: 0x43, registerValue: 0x63),
    TestInput(value: 0x80, registerValue: 0x81),
    TestInput(value: 0xCC, registerValue: 0xCC)
]

fileprivate let testOutputs = [
    TestOutput(C: false, Z: false, N: false),
    TestOutput(C: false, Z: false, N: true),
    TestOutput(C: true, Z: true, N: false),
    //        TestOutput(C: false, Z: true, N: true), Impossible since Z == true implies C == true for CMP.
    TestOutput(C: true, Z: false, N: false),
    TestOutput(C: true, Z: false, N: true),
    //        TestOutput(C: true, Z: true, N: false), Already tested above as we can't have (C: false, Z: true, N: false)
    TestOutput(C: true, Z: true, N: true)
]

fileprivate func testCMP(cpu: CPU6502, testOutput: TestOutput) {
    #expect(cpu.readFlag(flag: .C) == testOutput.C)
    #expect(cpu.readFlag(flag: .Z) == testOutput.Z)
    #expect(cpu.readFlag(flag: .N) == testOutput.N)
}

struct CompareTests {
    
    struct TestCMP {
        
        @Test func testCMP_Immediate() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CMP_Immediate.rawValue
                memory[0xFFFD] = testInput.value
                
                cpu.runForTicks(2)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_ZeroPage() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CMP_ZeroPage.rawValue
                memory[0xFFFD] = 0x55
                memory[0x55] = testInput.value
                
                cpu.runForTicks(3)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_ZeroPageX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.X = 0x10
                memory[0xFFFC] = Opcodes6502.CMP_ZeroPageX.rawValue
                memory[0xFFFD] = 0x55
                memory[0x65] = testInput.value
                
                cpu.runForTicks(4)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CMP_Absolute.rawValue
                memory[0xFFFD] = 0x34
                memory[0xFFFE] = 0x12
                memory[0x1234] = testInput.value
                
                cpu.runForTicks(4)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_AbsoluteX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // No page boundary crossed.
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.X = 0x10
                
                memory[0xFFFC] = Opcodes6502.CMP_AbsoluteX.rawValue
                memory[0xFFFD] = 0x78
                memory[0xFFFE] = 0x56
                memory[0x5688] = testInput.value
                
                cpu.runForTicks(4)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
            
            // Page boundary crossed.
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.X = 0x10
                memory[0xFFFC] = Opcodes6502.CMP_AbsoluteX.rawValue
                memory[0xFFFD] = 0xF0
                memory[0xFFFE] = 0xA0
                memory[0xA100] = testInput.value
                
                let oldTickcount = cpu.tickcount
                cpu.runForTicks(5)
                #expect(cpu.tickcount - oldTickcount == 5)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_AbsoluteY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // No page boundary crossed.
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.Y = 0x10
                memory[0xFFFC] = Opcodes6502.CMP_AbsoluteY.rawValue
                memory[0xFFFD] = 0x73
                memory[0xFFFE] = 0x19
                memory[0x1983] = testInput.value
                
                let oldTickcount = cpu.tickcount
                cpu.runForTicks(4)
                #expect(cpu.tickcount - oldTickcount == 4)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
            
            // Page boundary crossed.
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.Y = 0x10
                memory[0xFFFC] = Opcodes6502.CMP_AbsoluteY.rawValue
                memory[0xFFFD] = 0xF0
                memory[0xFFFE] = 0x40
                memory[0x4100] = testInput.value
                
                let oldTickcount = cpu.tickcount
                cpu.runForTicks(5)
                #expect(cpu.tickcount - oldTickcount == 5)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_IndirectX() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.X = 0x10
                memory[0xFFFC] = Opcodes6502.CMP_IndirectX.rawValue
                memory[0xFFFD] = 0x42
                memory[0x52] = 0x73
                memory[0x53] = 0x19
                memory[0x1973] = testInput.value
                
                cpu.runForTicks(6)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCMP_IndirectY() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            // No page boundary crossed.
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.Y = 0x10
                memory[0xFFFC] = Opcodes6502.CMP_IndirectY.rawValue
                memory[0xFFFD] = 0x22
                memory[0x22] = 0x04
                memory[0x23] = 0x20
                memory[0x2014] = testInput.value
                
                let oldTickcount = cpu.tickcount
                cpu.runForTicks(5)
                #expect(cpu.tickcount - oldTickcount == 5)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
            
            // Page boundary crossed.
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.A = testInput.registerValue
                cpu.Y = 0x40
                memory[0xFFFC] = Opcodes6502.CMP_IndirectY.rawValue
                memory[0xFFFD] = 0x22
                memory[0x22] = 0xF0
                memory[0x23] = 0x30
                memory[0x3130] = testInput.value
                
                let oldTickcount = cpu.tickcount
                cpu.runForTicks(6)
                #expect(cpu.tickcount - oldTickcount == 6)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
    }
    
    struct TestCPX {
        @Test func testCPX_Immediate() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.X = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CPX_Immediate.rawValue
                memory[0xFFFD] = testInput.value
                
                cpu.runForTicks(2)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCPX_ZeroPage() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.X = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CPX_ZeroPage.rawValue
                memory[0xFFFD] = 0x55
                memory[0x55] = testInput.value
                
                cpu.runForTicks(3)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCPX_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.X = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CPX_Absolute.rawValue
                memory[0xFFFD] = 0x34
                memory[0xFFFE] = 0x12
                memory[0x1234] = testInput.value
                
                cpu.runForTicks(4)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
    }
    
    struct TestCPY {
        @Test func testCPY_Immediate() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.Y = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CPY_Immediate.rawValue
                memory[0xFFFD] = testInput.value
                
                cpu.runForTicks(2)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCPY_ZeroPage() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.Y = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CPY_ZeroPage.rawValue
                memory[0xFFFD] = 0x55
                memory[0x55] = testInput.value
                
                cpu.runForTicks(3)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
        
        @Test func testCPY_Absolute() async throws {
            let (cpu, memory) = testCPU()
            defer { memory.deallocate() }
            
            for (i, testInput) in testInputs.enumerated() {
                cpu.reset()
                cpu.Y = testInput.registerValue
                memory[0xFFFC] = Opcodes6502.CPY_Absolute.rawValue
                memory[0xFFFD] = 0x34
                memory[0xFFFE] = 0x12
                memory[0x1234] = testInput.value
                
                cpu.runForTicks(4)
                testCMP(cpu: cpu, testOutput: testOutputs[i])
            }
        }
    }
}
