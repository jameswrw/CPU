//
//  BranchTests.swift
//  Swift6502
//
//  Created by James Weatherley on 14/11/2025.
//

import Testing
@testable import Swift6502

// With all the branch tests give ourselves some space by first doing a JMP away from the rest vector.
//
// From: http://www.6502.org/tutorials/6502opcodes.html#PC
// When calculating branches a forward branch of 6 skips the following 6 bytes so, effectively the program counter points to the address that is 8 bytes beyond the address of the branch opcode; and a backward branch of $FA (256-6) goes to an address 4 bytes before the branch instruction.
//
// For example in the first test the branch instruction is at 0x1234 and the delta is 0x10, but we end up at 0x1246 as we jump from where the PC is once it has read the opcode and operand, and not from the addresss of the opcode.
//
// Also, these tests explicity check the tickcount as it varied depending on whether the branch was taken or not, and if so did it cross a page boundary.

struct BranchTests {
    
    // All the flag tests are very similar, so consolidate them into a shared utility function.
    func testBranch(flag: Flags, branchIfFlagSet: Bool, opcode: Opcodes6502) async throws {
        let (cpu, memory) = initCPU()
        defer { memory.deallocate() }
        
        // Simple branch forwards.
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x34
        memory[Int(cpu.resetVector + 2)] = 0x12
        memory[0x1234] = opcode.rawValue
        memory[0x1235] = 0x10
        branchIfFlagSet ? cpu.setFlag(flag) : cpu.clearFlag(flag)

        // JMP to 0x1234
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1234)
        
        var oldTickcount = cpu.tickcount
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1246)
        #expect(cpu.tickcount == oldTickcount + 3)

        // Simple branch backwards.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x34
        memory[Int(cpu.resetVector + 2)] = 0x12
        memory[0x1234] = opcode.rawValue
        memory[0x1235] = 0xF0   // -0x10
        branchIfFlagSet ? cpu.setFlag(flag) : cpu.clearFlag(flag)
        
        // JMP to 0x1234
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1234)
        
        oldTickcount = cpu.tickcount
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1226)
        #expect(cpu.tickcount == oldTickcount + 3)
        
        // Branch forwards with a page change.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0xF0
        memory[Int(cpu.resetVector + 2)] = 0x10
        memory[0x10F0] = opcode.rawValue
        memory[0x10F1] = 0x10
        branchIfFlagSet ? cpu.setFlag(flag) : cpu.clearFlag(flag)

        // JMP to 0x10F0
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x10F0)
        
        let ticks = (opcode == .BVC ? 3 : 4)
        oldTickcount = cpu.tickcount
        cpu.runForTicks(ticks)
        #expect(cpu.PC == 0x1102)
        #expect(cpu.tickcount == oldTickcount + ticks)
        
        // Branch backwards with a page change.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x10
        memory[Int(cpu.resetVector + 2)] = 0x10
        memory[0x1010] = opcode.rawValue
        memory[0x1011] = 0xE0   // -0x20
        branchIfFlagSet ? cpu.setFlag(flag) : cpu.clearFlag(flag)

        // JMP to 0x1010
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1010)
        
        oldTickcount = cpu.tickcount
        cpu.runForTicks(ticks)
        #expect(cpu.PC == 0xFF2)
        #expect(cpu.tickcount == oldTickcount + ticks)
        
        // Test no branch if flag state is different from branchIfFlagSet.
        cpu.reset()
        memory[Int(cpu.resetVector)] = Opcodes6502.JMP_Absolute.rawValue
        memory[Int(cpu.resetVector + 1)] = 0x34
        memory[Int(cpu.resetVector + 2)] = 0x12
        memory[0x1234] = opcode.rawValue
        memory[0x1235] = 0x10
        branchIfFlagSet ? cpu.clearFlag(flag) : cpu.setFlag(flag)

        // JMP to 0x1234
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1234)
        
        oldTickcount = cpu.tickcount
        cpu.runForTicks(2)
        #expect(cpu.PC == 0x1236)
        #expect(cpu.tickcount == oldTickcount + 2)
    }
    
    @Test func testBCC() async throws {
        try await testBranch(flag: .C, branchIfFlagSet: false, opcode: .BCC)
    }
    
    @Test func testBCS() async throws {
        try await testBranch(flag: .C, branchIfFlagSet: true, opcode: .BCS)
    }
    
    @Test func testBEQ() async throws {
        try await testBranch(flag: .Z, branchIfFlagSet: true, opcode: .BEQ)
    }
    
    @Test func testBNE() async throws {
        try await testBranch(flag: .Z, branchIfFlagSet: false, opcode: .BNE)
    }
    
    @Test func testBMI() async throws {
        try await testBranch(flag: .N, branchIfFlagSet: true, opcode: .BMI)
    }
    
    @Test func testBPL() async throws {
        try await testBranch(flag: .N, branchIfFlagSet: false, opcode: .BPL)
    }
    
    @Test func testBVC() async throws {
        try await testBranch(flag: .V, branchIfFlagSet: false, opcode: .BVC)
    }
    
    @Test func testBVS() async throws {
        try await testBranch(flag: .V, branchIfFlagSet: true, opcode: .BVS)
    }
}
