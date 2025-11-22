//
//  addHexTests.swift
//  Swift6502
//
//  Created by James Weatherley on 19/11/2025.
//

import Testing
@testable import Swift6502

struct AddHexTests {
    
    @Test func test_addHexNoCarry() async throws {
        try await test_addHex(setCarryFlag: false)
    }
    
    @Test func test_addDecimalCarry() async throws {
        try await test_addHex(setCarryFlag: true)
    }
    
    func test_addHex(setCarryFlag: Bool) async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        for i: UInt8 in 0..<0xFF {
            for j: UInt8 in 0..<0xFF {
                setCarryFlag ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                
                // The expectations are fairly trivial for hex as compared to decimal, in that
                // they basically replicate the flag setting algorithms in addHex().
                let result = cpu.addHex(i, to: j)
                #expect(result == i &+ j &+ (setCarryFlag ? 1 : 0))
                
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
                
                if UInt16(i) + UInt16(j) + (setCarryFlag ? 1 : 0) > 0xFF {
                    #expect(cpu.readFlag(.C))
                } else {
                    #expect(!cpu.readFlag(.C))
                }
                
                if (i ^ result) & (j ^ result) & 0x80 != 0 {
                    #expect(cpu.readFlag(.V))
                } else {
                    #expect(!cpu.readFlag(.V))
                }
            }
        }
    }
}
