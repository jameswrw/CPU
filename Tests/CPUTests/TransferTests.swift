//
//  TransferTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

import Testing
@testable import CPU

struct TransferTests {
    @Test func testTAX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.A = 0x64
        memory[Int(cpu.resetVector)] = Opcodes6502.TAX.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0x64)
        #expect(cpu.X == 0x64)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.A = 0x00
        cpu.X = 0x12
        memory[Int(cpu.resetVector)] = Opcodes6502.TAX.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.X == 0)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.A = 0xFF
        memory[Int(cpu.resetVector)] = Opcodes6502.TAX.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0xFF)
        #expect(cpu.X == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
    
    @Test func testTXA() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.X = 0x64
        memory[Int(cpu.resetVector)] = Opcodes6502.TXA.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0x64)
        #expect(cpu.X == 0x64)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.X = 0x00
        cpu.A = 0x12
        memory[Int(cpu.resetVector)] = Opcodes6502.TXA.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.X == 0)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.A = 0x12
        cpu.X = 0xFF
        memory[Int(cpu.resetVector)] = Opcodes6502.TXA.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0xFF)
        #expect(cpu.X == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
    
    @Test func testTAY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.A = 0x64
        memory[Int(cpu.resetVector)] = Opcodes6502.TAY.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0x64)
        #expect(cpu.Y == 0x64)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.A = 0x00
        cpu.Y = 0x12
        memory[Int(cpu.resetVector)] = Opcodes6502.TAY.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.Y == 0)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.A = 0xFF
        memory[Int(cpu.resetVector)] = Opcodes6502.TAY.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0xFF)
        #expect(cpu.Y == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
    
    @Test func testTYA() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.Y = 0x64
        memory[Int(cpu.resetVector)] = Opcodes6502.TYA.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0x64)
        #expect(cpu.Y == 0x64)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.Y = 0x00
        cpu.A = 0x12
        memory[Int(cpu.resetVector)] = Opcodes6502.TYA.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0)
        #expect(cpu.Y == 0)
        #expect(cpu.readFlag(.Z) == true)
        #expect(cpu.readFlag(.N) == false)
        
        cpu.reset()
        cpu.A = 0x12
        cpu.Y = 0xFF
        memory[Int(cpu.resetVector)] = Opcodes6502.TYA.rawValue

        cpu.runForTicks(2)
        #expect(cpu.A == 0xFF)
        #expect(cpu.Y == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
}
