//
//  subtractHexTests.swift
//  Swift6502
//
//  Created by James Weatherley on 19/11/2025.
//

import Testing
@testable import Swift6502

struct SubtractHexTests {
    
    @Test func test_subtractHexNoCarry() async throws {
        try await test_subtractHex(setCarryFlag: false)
    }
    
    @Test func test_subtractHexCarry() async throws {
        try await test_subtractHex(setCarryFlag: true)
    }
    
    func test_subtractHex(setCarryFlag: Bool) async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for i: UInt8 in 0..<0xFF {
            for j: UInt8 in 0..<0xFF {
                setCarryFlag ? cpu.setFlag(.C) : cpu.clearFlag(.C)

                // The expectations are fairly trivial for hex as compared to decimal, in that
                // they basically replicate the flag setting algorithms in addHex().
                let result = cpu.subtractHex(i, from: j)
                #expect(result == j &- i &- (setCarryFlag ? 0 : 1))
                
                // It's tempting to do something like 'cpu.readFlag(.Z) && (hex_ij == 0x00)'
                // It doesn't work because short circuiting leads to 'false == <not evaluated>', and
                // #expected doesn't like that.
                if result == 0x00 {
                    #expect(cpu.readFlag(.Z))
                } else {
                    #expect(!cpu.readFlag(.Z))
                }
                
                if result & 0x80 != 0 {
                    #expect(cpu.readFlag(.N))
                } else {
                    #expect(!cpu.readFlag(.N))
                }
                
                if Int16(j) - Int16(i) - (setCarryFlag ? 0 : 1) >= 0 {
                    #expect(cpu.readFlag(.C))
                } else {
                    #expect(!cpu.readFlag(.C))
                }
                
                if (j ^ result) & (j ^ i) & 0x80 != 0 {
                    #expect(cpu.readFlag(.V))
                } else {
                    #expect(!cpu.readFlag(.V))
                }
            }
        }
    }
}
