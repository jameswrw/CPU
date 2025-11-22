//
//  StackTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import Swift6502

struct StackTests {
    @Test func testTSX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.X = 0x42
        memory[Int(cpu.resetVector)] = Opcodes6502.TSX.rawValue
        
        cpu.runForTicks(2)
        #expect(cpu.X == 0xFF)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == Flags.One.rawValue | Flags.I.rawValue)
    }
    
    @Test func testTXS() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.X = 0x42
        memory[Int(cpu.resetVector)] = Opcodes6502.TXS.rawValue

        cpu.runForTicks(2)
        #expect(cpu.X == 0x42)
        #expect(cpu.SP == 0x42)
        #expect(cpu.F == Flags.One.rawValue | Flags.I.rawValue)
    }
    
    @Test func testPHA() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.A = 0x73
        memory[Int(cpu.resetVector)] = Opcodes6502.PHA.rawValue
        memory[0x1FF] = 0x00
        
        cpu.runForTicks(3)
        #expect(cpu.A == 0x73)
        #expect(cpu.SP == 0xFE)
        #expect(memory[0x1FF] == 0x73)
    }
    
    @Test func testPLA() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.SP = 0xFE
        memory[Int(cpu.resetVector)] = Opcodes6502.PLA.rawValue
        memory[0x1FF] = 0xFF
        
        cpu.runForTicks(4)
        #expect(cpu.A == 0xFF)
        #expect(cpu.SP == 0xFF)
    }
    
    @Test func testPHP() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        memory[Int(cpu.resetVector)] = Opcodes6502.PHP.rawValue
        memory[0x1FF] = 0x00
        
        cpu.runForTicks(3)
        #expect(cpu.SP == 0xFE)
        #expect(memory[0x1FF] == Flags.One.rawValue | Flags.I.rawValue)
    }
    
    @Test func testPLP() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.SP = 0xFE
        memory[Int(cpu.resetVector)] = Opcodes6502.PLP.rawValue
        memory[0x1FF] = 0xAA
        
        cpu.runForTicks(4)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.F == 0xAA)
    }
}
