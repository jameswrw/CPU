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
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.CLC.rawValue
        cpu.setFlag(.C)
        #expect(cpu.readFlag(.C) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.C) == false)
    }
    
    @Test func testCLD() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.CLD.rawValue
        cpu.setFlag(.D)
        #expect(cpu.readFlag(.D) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.D) == false)
    }
    
    @Test func testCLI() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
    
        memory[0xFFFC] = Opcodes6502.CLI.rawValue
        cpu.setFlag(.I)
        #expect(cpu.readFlag(.I) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.I) == false)
    }
    
    @Test func testCLV() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.CLV.rawValue
        cpu.setFlag(.V)
        #expect(cpu.readFlag(.V) == true)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.V) == false)
    }
    
    @Test func testSEC() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.SEC.rawValue
        #expect(cpu.readFlag(.C) == false)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.C) == true)
    }
    
    @Test func testSED() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.SED.rawValue
        #expect(cpu.readFlag(.D) == false)

        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.D) == true)
    }
    
    @Test func testSEI() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[0xFFFC] = Opcodes6502.SEI.rawValue
        #expect(cpu.readFlag(.I) == false)
        
        cpu.runForTicks(2)
        #expect(cpu.PC == 0xFFFD)
        #expect(cpu.readFlag(.I) == true)

    }
}
