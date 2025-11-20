//
//  ORTests.swift
//  CPU
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import CPU

struct ORTests {
    
    fileprivate let payloads = [
        BitwiseTestPayload(initialA: 0x55, operand: 0x42, result: 0x57, Z: false, N: false),
        BitwiseTestPayload(initialA: 0xF0, operand: 0xCC, result: 0xFC, Z: false, N: true),
        BitwiseTestPayload(initialA: 0x00, operand: 0x00, result: 0x00, Z: true, N: false),
    // BitwiseTestPayload(initialA: 0x00, operand: 0x00, Z: true, N: true), Impossible we can't be negative OR zero at the same time.
    ]
    
    @Test func testORA_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            memory[0xFFFC] = Opcodes6502.ORA_Immediate.rawValue
            memory[0xFFFD] = payload.operand
            
            cpu.runForTicks(2)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testORA_ZerPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            memory[0xFFFC] = Opcodes6502.ORA_ZeroPage.rawValue
            memory[0xFFFD] = 0x06
            memory[0x06] = payload.operand
            
            cpu.runForTicks(2)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testORA_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.X = 0x10
            memory[0xFFFC] = Opcodes6502.ORA_ZeroPageX.rawValue
            memory[0xFFFD] = 0x32
            memory[0x42] = payload.operand
            
            cpu.runForTicks(4)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testORA_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            memory[0xFFFC] = Opcodes6502.ORA_Absolute.rawValue
            memory[0xFFFD] = 0x34
            memory[0xFFFE] = 0x12
            memory[0x1234] = payload.operand
            
            cpu.runForTicks(4)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testORA_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.X = 0x10
            memory[0xFFFC] = Opcodes6502.ORA_AbsoluteX.rawValue
            memory[0xFFFD] = 0x78
            memory[0xFFFE] = 0x56
            memory[0x5688] = payload.operand
            
            cpu.runForTicks(4)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
        
        // Test crossing a page boundary takes five ticks instead of four.
        cpu.reset()
        cpu.A = 0x33
        cpu.X = 0x20
        memory[0xFFFC] = Opcodes6502.ORA_AbsoluteX.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x56
        memory[0x5710] = 0x17
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.A == 0x37)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testORA_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.Y = 0x10
            memory[0xFFFC] = Opcodes6502.ORA_AbsoluteY.rawValue
            memory[0xFFFD] = 0x78
            memory[0xFFFE] = 0x56
            memory[0x5688] = payload.operand
            
            cpu.runForTicks(4)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
        
        // Test crossing a page boundary takes five ticks instead of four.
        cpu.reset()
        cpu.A = 0x33
        cpu.Y = 0x20
        memory[0xFFFC] = Opcodes6502.ORA_AbsoluteY.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x56
        memory[0x5710] = 0x17
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.A == 0x37)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testORA_IndirectX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.X = 0x20
            memory[0xFFFC] = Opcodes6502.ORA_IndirectX.rawValue
            memory[0xFFFD] = 0x66
            memory[0x86] = 0x73
            memory[0x87] = 0x19
            memory[0x1973] = payload.operand
            
            cpu.runForTicks(6)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testORA_IndirectY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.Y = 0x20
            memory[0xFFFC] = Opcodes6502.ORA_IndirectY.rawValue
            memory[0xFFFD] = 0x66
            memory[0x66] = 0x73
            memory[0x67] = 0x19
            memory[0x1993] = payload.operand
            
            cpu.runForTicks(5)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
        
        // Test crossing a page boundary takes five ticks instead of four.
        cpu.reset()
        cpu.A = 0x7F
        cpu.Y = 0x20
        memory[0xFFFC] = Opcodes6502.ORA_IndirectY.rawValue
        memory[0xFFFD] = 0x66
        memory[0x66] = 0xF0
        memory[0x67] = 0x19
        memory[0x1A10] = 0x87
        
        cpu.runForTicks(5)
        #expect(cpu.A == 0xFF)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == true)
    }
}
