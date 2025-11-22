//
//  LoadTests.swift
//  Swift6502
//
//  Created by James Weatherley on 13/11/2025.
//

internal struct LoadTestOutput {
    let value: UInt8
    let Z: Bool
    let N: Bool
}

internal let loadTestOutputs = [
    LoadTestOutput(value: 0x42, Z: false, N: false),
    LoadTestOutput(value: 0xA0, Z: false, N: true),
    LoadTestOutput(value: 0x00, Z: true, N: false),
// LoadTestOutput(value: 0x00, Z: true, N: true), Impossible we can't be negative and zero at the same time.
]
