//
//  FlagTests.swift
//  CPU
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct FlagTests {
    @Test func testCLC() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.CLC.rawValue
        cpu.setFlag(flag: .C)
        #expect(cpu.readFlag(flag: .C) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .C) == false)
    }
    
    @Test func testCLD() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.CLD.rawValue
        cpu.setFlag(flag: .D)
        #expect(cpu.readFlag(flag: .D) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .D) == false)
    }
    
    @Test func testCLI() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
    
        memory[0xFFFC] = Opcodes6502.CLI.rawValue
        cpu.setFlag(flag: .I)
        #expect(cpu.readFlag(flag: .I) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .I) == false)
    }
    
    @Test func testCLV() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.CLV.rawValue
        cpu.setFlag(flag: .V)
        #expect(cpu.readFlag(flag: .V) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .V) == false)
    }
    
    @Test func testSEC() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.SEC.rawValue
        #expect(cpu.readFlag(flag: .C) == false)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .C) == true)
    }
    
    @Test func testSED() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.SED.rawValue
        #expect(cpu.readFlag(flag: .D) == false)

        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .D) == true)
    }
    
    @Test func testSEI() async throws {
        let (cpu, memory) = testCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.SEI.rawValue
        #expect(cpu.readFlag(flag: .I) == false)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(flag: .I) == true)

    }
}
