//
//  LDYTests.swift
//  Swift6502
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import CPU

struct TestLDY {
    @Test func testLDX_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[Int(cpu.resetVector)] = Opcodes6502.LDY_Immediate.rawValue
            memory[Int(cpu.resetVector + 1)] = testOutput.value
            
            cpu.runForTicks(2)
            #expect(cpu.Y == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDX_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[Int(cpu.resetVector)] = Opcodes6502.LDY_ZeroPage.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x42] = testOutput.value
            
            cpu.runForTicks(3)
            #expect(cpu.Y == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDY_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.X = 0x10
            memory[Int(cpu.resetVector)] = Opcodes6502.LDY_ZeroPageX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x52] = testOutput.value
            
            cpu.runForTicks(4)
            #expect(cpu.Y == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDY_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[Int(cpu.resetVector)] = Opcodes6502.LDY_Absolute.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1973] = testOutput.value
            
            cpu.runForTicks(4)
            #expect(cpu.Y == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDY_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.X = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.LDY_AbsoluteX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1993] = testOutput.value
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(4)
            #expect(cpu.tickcount - oldTickcount == 4)
            #expect(cpu.Y == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
        
        // Bonus page boundary crossing test.
        cpu.reset()
        cpu.X = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.LDY_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[Int(cpu.resetVector + 2)] = 0x19
        memory[0x1A10] = 0x99
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.Y == 0x99)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
}
