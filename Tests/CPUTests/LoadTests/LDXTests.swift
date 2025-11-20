//
//  LDXTests.swift
//  CPU
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import CPU

struct LDXTests {
    @Test func testLDX_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.LDX_Immediate.rawValue
            memory[0xFFFD] = testOutput.value
            
            cpu.runForTicks(2)
            #expect(cpu.X == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDX_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.LDX_ZeroPage.rawValue
            memory[0xFFFD] = 0x42
            memory[0x42] = testOutput.value
            
            cpu.runForTicks(3)
            #expect(cpu.X == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDA_ZeroPageY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.Y = 0x10
            memory[0xFFFC] = Opcodes6502.LDX_ZeroPageY.rawValue
            memory[0xFFFD] = 0x42
            memory[0x52] = testOutput.value
            
            cpu.runForTicks(4)
            #expect(cpu.X == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDX_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            memory[0xFFFC] = Opcodes6502.LDX_Absolute.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1973] = testOutput.value
            
            cpu.runForTicks(4)
            #expect(cpu.X == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
    }
    
    @Test func testLDX_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for testOutput in loadTestOutputs {
            cpu.reset()
            cpu.Y = 0x20
            memory[0xFFFC] = Opcodes6502.LDX_AbsoluteY.rawValue
            memory[0xFFFD] = 0x73
            memory[0xFFFE] = 0x19
            memory[0x1993] = testOutput.value
            
            let oldTickcount = cpu.tickcount
            cpu.runForTicks(4)
            #expect(cpu.tickcount - oldTickcount == 4)
            #expect(cpu.X == testOutput.value)
            #expect(cpu.readFlag(.Z) == testOutput.Z)
            #expect(cpu.readFlag(.N) == testOutput.N)
        }
        
        // Bonus page boundary crossing test.
        cpu.reset()
        cpu.Y = 0x20
        memory[0xFFFC] = Opcodes6502.LDX_AbsoluteY.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x19
        memory[0x1A10] = 0x99
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.X == 0x99)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
}
