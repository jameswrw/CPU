//
//  MemoryControllerTests.swift
//  Swift6502
//
//  Created by James Weatherley on 22/11/2025.
//

import Testing
@testable import Swift6502

struct MemoryControllerTests {
    
    @Test func testIORead() async throws {
        let (cpu, memory) = initCPU(ioAddresses: [0x2000, 0x2001])
        defer { memory.deallocate() }
        
        cpu.setIOReadCallback { address in
            if address == 0x2000 {
                memory[0x3000] = 0x22
            } else if address == 0x2001 {
                memory[0x3001] = 0x33
            }
            return 0x42
        }

        // • JMP to 0x1000.
        // • Read (LDA) from 0x2000 and 0x2001.
        // • Reading from 0x2000 causes cpu.memory.ioReadCallback to set 0x3000 to 0x22.
        // • Reading from 0x2001 causes cpu.memory.ioReadCallback to set 0x3001 to 0x33.
        //
        // Note: Memory accesses are via cpu.memoryController sees them.
        //       Directly reading from memory is, well, a DMA and the ioCallbacks will not be called.
        
        cpu.memory[0xA000] = Opcodes6502.JMP_Absolute.rawValue
        cpu.memory[0xA001] = 0x00
        cpu.memory[0xA002] = 0x10
        cpu.memory[0x1000] = Opcodes6502.LDA_Absolute.rawValue
        cpu.memory[0x1001] = 0x00
        cpu.memory[0x1002] = 0x20
        cpu.memory[0x1003] = Opcodes6502.LDA_Absolute.rawValue
        cpu.memory[0x1004] = 0x01
        cpu.memory[0x1005] = 0x20
        
        #expect(cpu.memory[0x3000] == 0xFF)
        #expect(cpu.memory[0x3001] == 0xFF)
        
        // JMP
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1000)
        
        // LDA
        cpu.runForTicks(4)
        #expect(cpu.memory[0x3000] == 0x22)
        #expect(cpu.memory[0x3001] == 0xFF)
        
        // LDA
        cpu.runForTicks(4)
        #expect(cpu.memory[0x3000] == 0x22)
        #expect(cpu.memory[0x3001] == 0x33)
    }
    
    @Test func testIOWrite() async throws {
        let (cpu, memory) = initCPU(ioAddresses: [0x2000, 0x2001])
        defer { memory.deallocate() }
        
        cpu.setIOWriteCallback { address, value in
            if address == 0x2000 {
                memory[0x3002] = 0xAB
            } else if address == 0x2001 {
                memory[0x3003] = 0xCD
            }
            return value
        }
        
        // • JMP to 0x1000.
        // • Write to 0x2000 and 0x2001.
        // • Writing to 0x2000 causes cpu.memory.ioReadCallback to set 0x3002 to 0xAB.
        // • Writing to 0x2001 causes cpu.memory.ioReadCallback to set 0x3003 to 0xCD.
        //
        // Note: Memory accesses are via cpu.memoryController sees them.
        //       Directly reading from memory is, well, a DMA and the ioCallbacks will not be called.
        
        cpu.memory[0xA000] = Opcodes6502.JMP_Absolute.rawValue
        cpu.memory[0xA001] = 0x00
        cpu.memory[0xA002] = 0x10
        cpu.memory[0x1000] = Opcodes6502.STA_Absolute.rawValue
        cpu.memory[0x1001] = 0x00
        cpu.memory[0x1002] = 0x20
        cpu.memory[0x1003] = Opcodes6502.STA_Absolute.rawValue
        cpu.memory[0x1004] = 0x01
        cpu.memory[0x1005] = 0x20
        
        #expect(cpu.memory[0x3002] == 0xFF)
        #expect(cpu.memory[0x3003] == 0xFF)
        
        cpu.runForTicks(3)
        #expect(cpu.PC == 0x1000)
        
        cpu.runForTicks(4)
        #expect(cpu.memory[0x3002] == 0xAB)
        #expect(cpu.memory[0x3003] == 0xFF)
        
        cpu.runForTicks(4)
        #expect(cpu.memory[0x3002] == 0xAB)
        #expect(cpu.memory[0x3003] == 0xCD)
    }
}
