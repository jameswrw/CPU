//
//  StoreTests.swift
//  CPU
//
//  Created by James Weatherley on 16/11/2025.
//

import Testing
@testable import CPU

struct StoreTests {
    
    struct TestSTA {
        @Test func testSTA_ZeroPage() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_ZeroPage.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x42] = 0x66
            
            cpu.runForTicks(3)
            #expect(cpu.A == 0x66)
        }
        
        @Test func testSTA_ZeroPageX() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            cpu.X = 0x10
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_ZeroPageX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x55
            memory[0x65] = 0x22

            cpu.runForTicks(4)
            #expect(cpu.A == 0x22)
        }
        
        @Test func testSTA_Absolute() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_Absolute.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1973] = 0x28
            
            cpu.runForTicks(4)
            #expect(cpu.A == 0x28)
        }
        
        @Test func testSTA_AbsoluteX() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            cpu.X = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_AbsoluteX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1993] = 0x32
            
            cpu.runForTicks(5)
            #expect(cpu.A == 0x32)
        }
        
        @Test func testSTA_AbsoluteY() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            cpu.Y = 0x10
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_AbsoluteY.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x04
            memory[Int(cpu.resetVector + 2)] = 0x20
            memory[0x2014] = 0x64
            
            cpu.runForTicks(5)
            #expect(cpu.A == 0x64)
        }
        
        @Test func testSTA_IndirectX() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            cpu.X = 0x10
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_IndirectX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x50
            memory[0x60] = 0x80
            memory[0x61] = 0x19
            memory[0x1980] = 0xBC
            
            cpu.runForTicks(6)
            #expect(cpu.A == 0xBC)
        }
        
        @Test func testSTA_IndirectY() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.A = 0x00
            cpu.Y = 0x20
            memory[Int(cpu.resetVector)] = Opcodes6502.STA_IndirectY.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x84
            memory[0x84] = 0x89
            memory[0x85] = 0x20
            memory[0x20A9] = 0x40

            cpu.runForTicks(6)
            #expect(cpu.A == 0x40)
        }
    }
    
    struct TestSTX {
        @Test func testSTX_Zeropage() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STX_ZeroPage.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x42] = 0x66
            
            cpu.runForTicks(3)
            #expect(cpu.X == 0x66)
        }
        
        @Test func testSTX_ZeropageY() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x00
            cpu.Y = 0x10
            memory[Int(cpu.resetVector)] = Opcodes6502.STX_ZeroPageY.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x55
            memory[0x65] = 0x22

            cpu.runForTicks(4)
            #expect(cpu.X == 0x22)
        }
        
        @Test func testSTX_Absolute() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STX_Absolute.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1973] = 0x28
            
            cpu.runForTicks(4)
            #expect(cpu.X == 0x28)
        }
    }
    
    struct TestSTY {
        @Test func testSTY_Zeropage() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.Y = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STY_ZeroPage.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x42
            memory[0x42] = 0x66
            
            cpu.runForTicks(3)
            #expect(cpu.Y == 0x66)
        }
        
        @Test func testSTY_ZeropageX() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.X = 0x10
            cpu.Y = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STY_ZeroPageX.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x55
            memory[0x65] = 0x22

            cpu.runForTicks(4)
            #expect(cpu.Y == 0x22)
        }
        
        @Test func testSTY_Absolute() async throws {
            let (cpu, memory) = initCPU()
            defer { memory.deallocate() }
            
            cpu.Y = 0x00
            memory[Int(cpu.resetVector)] = Opcodes6502.STY_Absolute.rawValue
            memory[Int(cpu.resetVector + 1)] = 0x73
            memory[Int(cpu.resetVector + 2)] = 0x19
            memory[0x1973] = 0x28
            
            cpu.runForTicks(4)
            #expect(cpu.Y == 0x28)
        }
    }
}
