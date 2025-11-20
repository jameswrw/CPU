//
//  SBCDecimalTests.swift
//  CPU
//
//  Created by James Weatherley on 20/11/2025.
//

import Testing
@testable import CPU

struct SBCDecimalTests {
    fileprivate let carryPayloads = [
        AddSubtractTestPayload(initialA: 0x35, operand: 0x30, result: 0x05, Z: false, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x00, operand: 0x01, result: 0x99, Z: false, N: true, C: true, V: false),
        AddSubtractTestPayload(initialA: 0x80, operand: 0x01, result: 0x79, Z: false, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x44, operand: 0x44, result: 0x00, Z: true, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x10, operand: 0xFF, result: 0x11, Z: false, N: false, C: true, V: false),
    ]
    
    fileprivate let noCarryPayloads = [
        AddSubtractTestPayload(initialA: 0x35, operand: 0x30, result: 0x04, Z: false, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x00, operand: 0x00, result: 0x99, Z: false, N: true, C: true, V: false),
        AddSubtractTestPayload(initialA: 0x80, operand: 0x01, result: 0x78, Z: false, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x44, operand: 0x43, result: 0x00, Z: true, N: false, C: false, V: false),
    ]
    
    @Test func testSBC_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                memory[0xFFFC] = Opcodes6502.SBC_Immediate.rawValue
                memory[0xFFFD] = payload.operand
                
                cpu.runForTicks(2)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
    }
    
    @Test func testSBC_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                memory[0xFFFC] = Opcodes6502.SBC_ZeroPage.rawValue
                memory[0xFFFD] = 0x42
                memory[0x42] = payload.operand
                
                cpu.runForTicks(3)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
    }
    
    @Test func testSBC_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                cpu.X = 0x20
                memory[0xFFFC] = Opcodes6502.SBC_ZeroPageX.rawValue
                memory[0xFFFD] = 0x42
                memory[0x62] = payload.operand
                
                cpu.runForTicks(4)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
    }
    
    @Test func testSBC_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                memory[0xFFFC] = Opcodes6502.SBC_Absolute.rawValue
                memory[0xFFFD] = 0x34
                memory[0xFFFE] = 0x12
                memory[0x1234] = payload.operand
                
                cpu.runForTicks(4)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
    }
    
    @Test func testSBC_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                cpu.X = 0x20
                memory[0xFFFC] = Opcodes6502.SBC_AbsoluteX.rawValue
                memory[0xFFFD] = 0x34
                memory[0xFFFE] = 0x12
                memory[0x1254] = payload.operand
                
                cpu.runForTicks(4)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
        
        // Test crossing page boundary adds a tick.
        cpu.reset()
        cpu.setFlag(.C)
        cpu.setFlag(.D)
        cpu.A = 0x52
        cpu.X = 0x20
        memory[0xFFFC] = Opcodes6502.SBC_AbsoluteX.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x56
        memory[0x5710] = 0x32
        
        cpu.runForTicks(5)
        #expect(cpu.A == 0x20)
        #expect(!cpu.readFlag(.Z))
        #expect(!cpu.readFlag(.N))
        #expect(!cpu.readFlag(.C))
        #expect(!cpu.readFlag(.V))
    }
    
    @Test func testSBC_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                cpu.Y = 0x20
                memory[0xFFFC] = Opcodes6502.SBC_AbsoluteY.rawValue
                memory[0xFFFD] = 0x34
                memory[0xFFFE] = 0x12
                memory[0x1254] = payload.operand
                
                cpu.runForTicks(4)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
        
        // Test crossing page boundary adds a tick.
        cpu.reset()
        cpu.setFlag(.C)
        cpu.setFlag(.D)
        cpu.A = 0x52
        cpu.Y = 0x20
        memory[0xFFFC] = Opcodes6502.SBC_AbsoluteY.rawValue
        memory[0xFFFD] = 0xF0
        memory[0xFFFE] = 0x56
        memory[0x5710] = 0x32
        
        cpu.runForTicks(5)
        #expect(cpu.A == 0x20)
        #expect(!cpu.readFlag(.Z))
        #expect(!cpu.readFlag(.N))
        #expect(!cpu.readFlag(.C))
        #expect(!cpu.readFlag(.V))
    }
    
    @Test func testSBC_IndirectX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                cpu.X = 0x20
                memory[0xFFFC] = Opcodes6502.SBC_IndirectX.rawValue
                memory[0xFFFD] = 0x34
                memory[0x54] = 0x78
                memory[0x55] = 0x56
                memory[0x5678] = payload.operand
                
                cpu.runForTicks(6)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
    }
    
    @Test func testSBC_IndirectY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.setFlag(.D)
                cpu.A = payload.initialA
                cpu.Y = 0x20
                memory[0xFFFC] = Opcodes6502.SBC_IndirectY.rawValue
                memory[0xFFFD] = 0x34
                memory[0x34] = 0x78
                memory[0x35] = 0x56
                memory[0x5698] = payload.operand
                
                cpu.runForTicks(6)
                #expect(cpu.A == payload.result)
                #expect(cpu.readFlag(.Z) == payload.Z)
                #expect(cpu.readFlag(.N) == payload.N)
                #expect(cpu.readFlag(.C) == payload.C)
                #expect(cpu.readFlag(.V) == payload.V)
            }
            useCarry.toggle()
        }
        
        // Test crossing page boundary adds a tick.
        cpu.reset()
        cpu.setFlag(.C)
        cpu.setFlag(.D)
        cpu.A = 0x56
        cpu.Y = 0x20
        memory[0xFFFC] = Opcodes6502.SBC_IndirectY.rawValue
        memory[0xFFFD] = 0x52
        memory[0x52] = 0xF0
        memory[0x53] = 0x88
        memory[0x8910] = 0x42
        
        cpu.runForTicks(6)
        #expect(cpu.A == 0x14)
        #expect(!cpu.readFlag(.Z))
        #expect(!cpu.readFlag(.N))
        #expect(!cpu.readFlag(.C))
        #expect(!cpu.readFlag(.V))
    }
}
