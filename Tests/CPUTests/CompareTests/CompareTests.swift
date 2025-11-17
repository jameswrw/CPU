//
//  CompareTests.swift
//  CPU
//
//  Created by James Weatherley on 14/11/2025.
//

@testable import CPU
import Testing

internal struct CompareTestInput {
    let value: UInt8
    let registerValue: UInt8
}

internal struct CompareTestOutput {
    let C: Bool
    let Z: Bool
    let N: Bool
}

internal let compareTestInputs = [
    CompareTestInput(value: 0x34, registerValue: 0x24),
    CompareTestInput(value: 0x81, registerValue: 0x80),
    CompareTestInput(value: 0x53, registerValue: 0x53),
    CompareTestInput(value: 0x43, registerValue: 0x63),
    CompareTestInput(value: 0x80, registerValue: 0x81),
    CompareTestInput(value: 0xCC, registerValue: 0xCC)
]

internal let compareTestOutputs = [
    CompareTestOutput(C: false, Z: false, N: false),
    CompareTestOutput(C: false, Z: false, N: true),
    CompareTestOutput(C: true, Z: true, N: false),
    // CompareTestOutput(C: false, Z: true, N: true), Impossible since Z == true implies C == true for CMP.
    CompareTestOutput(C: true, Z: false, N: false),
    CompareTestOutput(C: true, Z: false, N: true),
    // CompareTestOutput(C: true, Z: true, N: false), Already tested above as we can't have (C: false, Z: true, N: false)
    CompareTestOutput(C: true, Z: true, N: true)
]

internal func testCMP(cpu: CPU6502, CompareTestOutput: CompareTestOutput) {
    #expect(cpu.readFlag(flag: .C) == CompareTestOutput.C)
    #expect(cpu.readFlag(flag: .Z) == CompareTestOutput.Z)
    #expect(cpu.readFlag(flag: .N) == CompareTestOutput.N)
}
