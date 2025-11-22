//
//  BitTests.swift
//  Swift6502
//
//  Created by James Weatherley on 14/11/2025.
//

import Testing
@testable import Swift6502

struct BitTests {
    
    struct ExpectedFlags {
        let Z: Bool
        let N: Bool
        let V: Bool
    }
    
    func testBIT_ZeroPage(value: UInt8, expectedFlags: ExpectedFlags) {
        
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Z = 0, N == 0, V == 0
        memory[0xA000] = Opcodes6502.BIT_ZeroPage.rawValue
        memory[0xA001] = 0x55
        memory[0x55] = value
        cpu.A = 0x06
        
        cpu.runForTicks(3)
        #expect(cpu.readFlag(.Z) == expectedFlags.Z)
        #expect(cpu.readFlag(.N) == expectedFlags.N)
        #expect(cpu.readFlag(.V) == expectedFlags.V)
    }
    
    func testBIT_Absolute(value: UInt8, expectedFlags: ExpectedFlags) {
        
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Z = 0, N == 0, V == 0
        memory[0xA000] = Opcodes6502.BIT_Absolute.rawValue
        memory[0xA001] = 0x34
        memory[0xA002] = 0x12

        memory[0x1234] = value
        cpu.A = 0x06
        
        cpu.runForTicks(4)
        #expect(cpu.readFlag(.Z) == expectedFlags.Z)
        #expect(cpu.readFlag(.N) == expectedFlags.N)
        #expect(cpu.readFlag(.V) == expectedFlags.V)
    }
    
    @Test func testBIT_ZeroPage() async throws {
        testBIT_ZeroPage(value: 0x06, expectedFlags: ExpectedFlags(Z: false, N: false, V: false))
        testBIT_ZeroPage(value: 0x46, expectedFlags: ExpectedFlags(Z: false, N: false, V: true))
        testBIT_ZeroPage(value: 0x86, expectedFlags: ExpectedFlags(Z: false, N: true, V: false))
        testBIT_ZeroPage(value: 0xC6, expectedFlags: ExpectedFlags(Z: false, N: true, V: true))
        testBIT_ZeroPage(value: 0x08, expectedFlags: ExpectedFlags(Z: true, N: false, V: false))
        testBIT_ZeroPage(value: 0x48, expectedFlags: ExpectedFlags(Z: true, N: false, V: true))
        testBIT_ZeroPage(value: 0x88, expectedFlags: ExpectedFlags(Z: true, N: true, V: false))
        testBIT_ZeroPage(value: 0xC8, expectedFlags: ExpectedFlags(Z: true, N: true, V: true))
    }
    
    @Test func testBIT_Absolute() async throws {
        testBIT_Absolute(value: 0x06, expectedFlags: ExpectedFlags(Z: false, N: false, V: false))
        testBIT_Absolute(value: 0x46, expectedFlags: ExpectedFlags(Z: false, N: false, V: true))
        testBIT_Absolute(value: 0x86, expectedFlags: ExpectedFlags(Z: false, N: true, V: false))
        testBIT_Absolute(value: 0xC6, expectedFlags: ExpectedFlags(Z: false, N: true, V: true))
        testBIT_Absolute(value: 0x08, expectedFlags: ExpectedFlags(Z: true, N: false, V: false))
        testBIT_Absolute(value: 0x48, expectedFlags: ExpectedFlags(Z: true, N: false, V: true))
        testBIT_Absolute(value: 0x88, expectedFlags: ExpectedFlags(Z: true, N: true, V: false))
        testBIT_Absolute(value: 0xC8, expectedFlags: ExpectedFlags(Z: true, N: true, V: true))
    }
    
}
