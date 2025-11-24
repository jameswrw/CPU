// Would like to replace testCPU() with a macro.
// It's written, but gives dubious errors about the _main symbol being missing when building.
//
// import CPUMacroDecls

import Testing
import Foundation
@testable import Swift6502

@inline(__always)
internal func initCPU(assertInitialState: Bool = true, ioAddresses: Set<UInt16> = []) -> (CPU6502, UnsafeMutablePointer<UInt8>) {
    let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)
    
    // 0xFF is an invalid opcode, so this should help catch some unitialised memory and tickcount issues.
    memset(memory, 0xFF, 0x10000)
    
    // Start all tests from 0xA000
    memory[0xFFFC] = 0x00
    memory[0xFFFD] = 0xA0
    let cpu = CPU6502(memory: MemoryWrapper(memory), ioAddresses: ioAddresses)

    if assertInitialState {
        #expect(cpu.A == 0)
        #expect(cpu.X == 0)
        #expect(cpu.Y == 0)
        #expect(cpu.SP == 0xFF)
        #expect(cpu.PC == cpu.readWord(addr: cpu.resetVector))
        #expect(cpu.F == Flags.One.rawValue | Flags.I.rawValue)
    }

    return (cpu, memory)
}
