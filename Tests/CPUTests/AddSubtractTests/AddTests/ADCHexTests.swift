//
//  ADCHexTests.swift
//  Swift6502
//
//  Created by James Weatherley on 20/11/2025.
//

import Testing
@testable import CPU

struct ADCHexTests {
    fileprivate let carryPayloads = [
        AddSubtractTestPayload(initialA: 0x35, operand: 0x42, result: 0x78, Z: false, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x45, operand: 0x44, result: 0x8A, Z: false, N: true, C: false, V: true),
        AddSubtractTestPayload(initialA: 0x75, operand: 0x10, result: 0x86, Z: false, N: true, C: false, V: true),
        AddSubtractTestPayload(initialA: 0xFE, operand: 0x01, result: 0x00, Z: true, N: false, C: true, V: false),
    ]
    
    fileprivate let noCarryPayloads = [
        AddSubtractTestPayload(initialA: 0x35, operand: 0x42, result: 0x77, Z: false, N: false, C: false, V: false),
        AddSubtractTestPayload(initialA: 0x45, operand: 0x44, result: 0x89, Z: false, N: true, C: false, V: true),
        AddSubtractTestPayload(initialA: 0x75, operand: 0x10, result: 0x85, Z: false, N: true, C: false, V: true),
        AddSubtractTestPayload(initialA: 0xFE, operand: 0x02, result: 0x00, Z: true, N: false, C: true, V: false),
    ]
    
    @Test func testADC_Immediate() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_Immediate.rawValue
                memory[Int(cpu.resetVector + 1)] = payload.operand
                
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
    
    @Test func testADC_ZeroPage() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_ZeroPage.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x42
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
    
    @Test func testADC_ZeroPageX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                cpu.X = 0x20
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_ZeroPageX.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x42
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
    
    @Test func testADC_Absolute() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_Absolute.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x34
                memory[Int(cpu.resetVector + 2)] = 0x12
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
    
    @Test func testADC_AbsoluteX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                cpu.X = 0x20
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_AbsoluteX.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x34
                memory[Int(cpu.resetVector + 2)] = 0x12
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
        cpu.A = 0x25
        cpu.X = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.ADC_AbsoluteX.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[Int(cpu.resetVector + 2)] = 0x56
        memory[0x5710] = 0x32
        
        cpu.runForTicks(5)
        #expect(cpu.A == 0x58)
        #expect(!cpu.readFlag(.Z))
        #expect(!cpu.readFlag(.N))
        #expect(!cpu.readFlag(.C))
        #expect(!cpu.readFlag(.V))
    }
    
    @Test func testADC_AbsoluteY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                cpu.Y = 0x20
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_AbsoluteY.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x34
                memory[Int(cpu.resetVector + 2)] = 0x12
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
        cpu.A = 0x25
        cpu.Y = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.ADC_AbsoluteY.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[Int(cpu.resetVector + 2)] = 0x56
        memory[0x5710] = 0x32
        
        cpu.runForTicks(5)
        #expect(cpu.A == 0x58)
        #expect(!cpu.readFlag(.Z))
        #expect(!cpu.readFlag(.N))
        #expect(!cpu.readFlag(.C))
        #expect(!cpu.readFlag(.V))
    }
    
    @Test func testADC_IndirectX() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                cpu.X = 0x20
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_IndirectX.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x34
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
    
    @Test func testADC_IndirectY() async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }

        var useCarry = true
        for _ in 0...1 {
            let payloads = (useCarry ? carryPayloads : noCarryPayloads)
            
            for payload in payloads {
                cpu.reset()
                useCarry ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                cpu.A = payload.initialA
                cpu.Y = 0x20
                memory[Int(cpu.resetVector)] = Opcodes6502.ADC_IndirectY.rawValue
                memory[Int(cpu.resetVector + 1)] = 0x34
                memory[0x34] = 0x78
                memory[0x35] = 0x56
                memory[0x5698] = payload.operand
                
                cpu.runForTicks(5)
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
        cpu.A = 0x56
        cpu.Y = 0x20
        memory[Int(cpu.resetVector)] = Opcodes6502.ADC_IndirectY.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x55
        memory[0x55] = 0xF0
        memory[0x56] = 0x88
        memory[0x8910] = 0x42
        
        cpu.runForTicks(6)
        #expect(cpu.A == 0x99)
        #expect(!cpu.readFlag(.Z))
        #expect(cpu.readFlag(.N))
        #expect(!cpu.readFlag(.C))
        #expect(cpu.readFlag(.V))
    }
}
