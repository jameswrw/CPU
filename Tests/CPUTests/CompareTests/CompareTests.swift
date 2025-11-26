//
//  CompareTests.swift
//  Swift6502
//
//  Created by James Weatherley on 14/11/2025.
//

@testable import Swift6502
import Testing

internal struct CompareTestInput {
    let memory: UInt8
    let registerValue: UInt8
}

internal struct CompareTestOutput {
    let C: Bool
    let Z: Bool
    let N: Bool
}

// Compare Result    N    Z    C
// Reg < Memory      *    0    0
// Reg = Memory      0    1    1
// Reg > Memory      *    0    1
//
// N (and Z) based on Reg - Memory

internal let compareTestInputs = [
    CompareTestInput(memory: 0x34, registerValue: 0x24),
    CompareTestInput(memory: 0x81, registerValue: 0x80),
    CompareTestInput(memory: 0x53, registerValue: 0x53),
    CompareTestInput(memory: 0x43, registerValue: 0x63),
    CompareTestInput(memory: 0x80, registerValue: 0x81),
    CompareTestInput(memory: 0xCC, registerValue: 0xCC)
]

internal let compareTestOutputs = [
    CompareTestOutput(C: false, Z: false, N: true),
    CompareTestOutput(C: false, Z: false, N: true),
    CompareTestOutput(C: true, Z: true, N: false),
    // CompareTestOutput(C: false, Z: true, N: true), Impossible since Z == true implies C == true for CMP.
    CompareTestOutput(C: true, Z: false, N: false),
    CompareTestOutput(C: true, Z: false, N: false),
    // CompareTestOutput(C: true, Z: true, N: false), Already tested above as we can't have (C: false, Z: true, N: false)
    CompareTestOutput(C: true, Z: true, N: false)
]

internal func testCMP(cpu: CPU6502, CompareTestOutput: CompareTestOutput) {
    #expect(cpu.readFlag(.C) == CompareTestOutput.C)
    #expect(cpu.readFlag(.Z) == CompareTestOutput.Z)
    #expect(cpu.readFlag(.N) == CompareTestOutput.N)
}
