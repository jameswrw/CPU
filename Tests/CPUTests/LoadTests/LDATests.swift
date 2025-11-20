//
//  LDATests.swift
//  CPU
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import CPU

struct LDATests {
    @Test func testLDA_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_Immediate.rawValue
            memory[Int(cpu.resetVector + 1)] = testOutput.value
            
            cpu.runForTicks(2)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDA_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_ZeroPage.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x42] = testOutput.value
            
            cpu.runForTicks(3)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDA_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.X = 0x10
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_ZeroPageX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x52] = testOutput.value
            
            cpu.runForTicks(4)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDA_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_Absolute.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1973] = testOutput.value
            
            cpu.runForTicks(4)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDA_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.X = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_AbsoluteX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1993] = testOutput.value
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(4)
            #expect(cpu.tickcount - oldTickcount == 4)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
        
        // Bonus page boundary crossing test.
        cpu.reset()
        cpu.X = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.LDA_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[Int(cpu.resetVector + 2)] = 0x19
        memory[0x1A10] = 0x42
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.A == 0x42)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testLDA_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.Y = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_AbsoluteY.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1993] = testOutput.value
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(4)
            #expect(cpu.tickcount - oldTickcount == 4)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
        
        // Bonus page boundary crossing test.
        cpu.reset()
        cpu.Y = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.LDA_AbsoluteY.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[Int(cpu.resetVector + 2)] = 0x19
        memory[0x1A10] = 0x99
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.A == 0x99)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
    
    @Test func testLDA_IndirectX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.X = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_IndirectX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x80
            memory[0xA0] = 0x69
            memory[0xA1] = 0x19
            memory[0x1969] = testOutput.value
            
            cpu.runForTicks(6)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDA_IndirectY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.Y = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.LDA_IndirectY.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x04
            memory[0x04] = 0x42
            memory[0x05] = 0x24
            memory[0x2462] = testOutput.value
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(5)
            #expect(cpu.tickcount - oldTickcount == 5)
            #expect(cpu.A == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
        
        // Bonus page boundary crossing test.
        cpu.reset()
        cpu.Y = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.LDA_IndirectY.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[0xF0] = 0xF0
        memory[0xF1] = 0x66
        memory[0x6710] = 0x34
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(6)
        #expect(cpu.tickcount - oldTickcount == 6)
        #expect(cpu.A == 0x34)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
}
