//
//  ANDTests.swift
//  CPU
//
//  Created by James Weatherley on 17/11/2025.
//

import Testing
@testable import CPU

struct ANDTests {
    
    fileprivate let payloads = [
        BitwiseTestPayload(initialA: 0x55, operand: 0x42, result: 0x40, Z: false, N: false),
        BitwiseTestPayload(initialA: 0xF0, operand: 0xCC, result: 0xC0, Z: false, N: true),
        BitwiseTestPayload(initialA: 0x55, operand: 0xAA, result: 0x00, Z: true, N: false),
    // BitwiseTestPayload(initialA: 0x00, operand: 0x00, Z: true, N: true), Impossible we can't be negative and zero at the same time.
    ]
    
    @Test func testAND_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            memory[0xFFFC] = Opcodes6502.AND_Immediate.rawValue
            memory[0xFFFD] = payload.operand
            
            cpu.runForTicks(2)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testAND_ZerPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            memory[0xFFFC] = Opcodes6502.AND_ZeroPage.rawValue
            memory[0xFFFD] = 0x06
            memory[0x06] = payload.operand
            
            cpu.runForTicks(2)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testAND_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.X = 0x10
            memory[0xFFFC] = Opcodes6502.AND_ZeroPageX.rawValue
            memory[0xFFFD] = 0x32
            memory[0x42] = payload.operand
            
            cpu.runForTicks(4)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testAND_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            memory[0xFFFC] = Opcodes6502.AND_Absolute.rawValue
            memory[0xFFFD] = 0x34
            memory[0xFFFE] = 0x12
            memory[0x1234] = payload.operand
            
            cpu.runForTicks(4)
            #expect(cpu.A == payload.result)
            #expect(cpu.readFlag(.Z) == payload.Z)
            #expect(cpu.readFlag(.N) == payload.N)
        }
    }
    
    @Test func testAND_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.X = 0x10
            memory[0xFFFC] = Opcodes6502.AND_AbsoluteX.rawValue
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
        memory[0xFFFC] = Opcodes6502.AND_AbsoluteX.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x56
        memory[0x5710] = 0x17
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.A == 0x13)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testAND_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.Y = 0x10
            memory[0xFFFC] = Opcodes6502.AND_AbsoluteY.rawValue
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
        memory[0xFFFC] = Opcodes6502.AND_AbsoluteY.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x56
        memory[0x5710] = 0x17
        
        let oldTickcount = cpu.tickcount
        cpu.runForTicks(5)
        #expect(cpu.tickcount - oldTickcount == 5)
        #expect(cpu.A == 0x13)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
    
    @Test func testAND_IndirectX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.X = 0x20
            memory[0xFFFC] = Opcodes6502.AND_IndirectX.rawValue
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
    
    @Test func testAND_IndirectY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for payload in payloads {
            cpu.reset()
            cpu.A = payload.initialA
            cpu.Y = 0x20
            memory[0xFFFC] = Opcodes6502.AND_IndirectY.rawValue
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
        memory[0xFFFC] = Opcodes6502.AND_IndirectY.rawValue
        memory[0xFFFD] = 0x66
        memory[0x66] = 0xF0
        memory[0x67] = 0x19
        memory[0x1A10] = 0x87
        
        cpu.runForTicks(5)
        #expect(cpu.A == 0x7)
        #expect(cpu.readFlag(.Z) == false)
        #expect(cpu.readFlag(.N) == false)
    }
}
