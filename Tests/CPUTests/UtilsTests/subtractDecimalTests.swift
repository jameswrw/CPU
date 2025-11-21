//
//  subtractDecimalTests.swift
//  CPU6502
//
//  Created by James Weatherley on 19/11/2025.
//

import Testing
@testable import CPU

struct SubtractDecimalTests {
    
    @Test func test_subtractDecimalNoCarry() async throws {
        try await test_subtractDecimal(setCarryFlag: false)
    }
    
    @Test func test_subtractDecimalCarry() async throws {
        try await test_subtractDecimal(setCarryFlag: true)
    }
    
    func test_subtractDecimal(setCarryFlag: Bool) async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.setFlag(.D)
        for hi_i: UInt8 in 0..<10 {
            for lo_i:UInt8 in 0..<10 {
                for hi_j: UInt8 in 0..<10 {
                    for lo_j:UInt8 in 0..<10 {
                        setCarryFlag ? cpu.setFlag(.C) : cpu.clearFlag(.C)
                        let hex_i = (hi_i << 4) | lo_i
                        let hex_j = (hi_j << 4) | lo_j
                        let dec_i = hi_i * 10 + lo_i
                        let dec_j = hi_j * 10 + lo_j
                        
                        var dec_ij = Int16(dec_j) - Int16(dec_i) - (setCarryFlag ? 0 : 1)
                        let hex_ij = cpu.subtractDecimal(hex_i, from: hex_j)
                        
                        if dec_ij < 0 {
                            dec_ij += 100
                            #expect(cpu.readFlag(.C))
                        } else {
                            #expect(!cpu.readFlag(.C))
                        }

                        // It's tempting to do something like 'cpu.readFlag(.Z) && (hex_ij == 0x00)'
                        // It doesn't work because short ciruiting leads to 'false == <not evaluated>', and
                        // #expected doesn't like that.
                        if hex_ij == 0x00 {
                            #expect(cpu.readFlag(.Z))
                        } else {
                            #expect(!cpu.readFlag(.Z))
                        }
                        
                        if hex_ij & 0x80 != 0 {
                            #expect(cpu.readFlag(.N))
                        } else {
                            #expect(!cpu.readFlag(.N))
                        }

                        let bcdResult = String(hex_ij, radix: 16)
                        #expect(bcdResult == String(dec_ij))
                    }
                }
            }
        }
        cpu.clearFlag(.D)
    }
}
