//
//  addDecimalTests.swift
//  CPU
//
//  Created by James Weatherley on 19/11/2025.
//

import Testing
@testable import CPU

struct AddDecimalTests {
    
    @Test func test_addDecimalNoCarry() async throws {
        try await test_addDecimal(setCarryFlag: false)
    }
    
    @Test func test_addDecimalCarry() async throws {
        try await test_addDecimal(setCarryFlag: true)
    }
    
    func test_addDecimal(setCarryFlag: Bool) async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        cpu.setFlag(flag: .D)
        for hi_i: UInt8 in 0..<10 {
            for lo_i:UInt8 in 0..<10 {
                for hi_j: UInt8 in 0..<10 {
                    for lo_j:UInt8 in 0..<10 {
                        setCarryFlag ? cpu.setFlag(flag: .C) : cpu.clearFlag(flag: .C)
                        let hex_i = (hi_i << 4) | lo_i
                        let hex_j = (hi_j << 4) | lo_j
                        let dec_i = hi_i * 10 + lo_i
                        let dec_j = hi_j * 10 + lo_j
                        
                        var dec_ij = dec_i + dec_j + (setCarryFlag ? 1 : 0)
                        let hex_ij = cpu.addDecimal(hex_i, to: hex_j)
                        
                        if dec_ij >= 100 {
                            dec_ij -= 100
                            #expect(cpu.readFlag(flag: .C))
                        } else {
                            #expect(!cpu.readFlag(flag: .C))
                        }

                        // It's tempting to do something like 'cpu.readFlag(flag: .Z) && (hex_ij == 0x00)'
                        // It doesn't work because short ciruiting leads to 'false == <not evaluated>', and
                        // #expected doesn't like that.
                        if hex_ij == 0x00 {
                            #expect(cpu.readFlag(flag: .Z))
                        } else {
                            #expect(!cpu.readFlag(flag: .Z))
                        }
                        
                        if hex_ij & 0x80 != 0 {
                            #expect(cpu.readFlag(flag: .N))
                        } else {
                            #expect(!cpu.readFlag(flag: .N))
                        }

                        let bcdResult = String(hex_ij, radix: 16)
                        #expect(bcdResult == String(dec_ij))
                    }
                }
            }
        }
        cpu.clearFlag(flag: .D)
    }
}
