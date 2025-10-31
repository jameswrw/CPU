//
//  CPU6502+Execute.swift
//  CPU
//
//  Created by James Weatherley on 30/10/2025.
//

public extension CPU6502 {
        
    func reset() {
        clearFlag(flag: .C)
        clearFlag(flag: .Z)
        clearFlag(flag: .I)
        clearFlag(flag: .D)
        clearFlag(flag: .B)
        setFlag(flag: .One)
        clearFlag(flag: .V)
        clearFlag(flag: .B)
        
        SP = 0xFF
        PC = 0xFFFC
        A = 0
        X = 0
        Y = 0
    }

    func run() {
        runForTicks(-1)
    }
    
    func runForTicks(_ ticks: Int) {
        let startTicks = tickcount
        
        while true {
            switch nextOpcode() {
            case .LDA_Absolute:
                A = readByte(addr: Int(PC))
                A == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (A & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .JMP_Absolute:
                PC = readWord16(addr: Int(PC))
                tickcount += 3
            case .JMP_Indirect:
                PC = readWord16(addr: Int(readWord16(addr: Int(PC))))     
                tickcount += 5
            case .TXS:
                SP = X
                tickcount += 2
            case .TSX:
                X = SP
                tickcount += 2
            case .PHA:
                memory[0x100 + Int(SP)] = A
                SP -= 1
                tickcount += 3
            case .PLA:
                SP += 1
                A = memory[0x100 + Int(SP)]
                tickcount += 4
            case .PHP:
                memory[0x100 + Int(SP)] = F
                SP -= 1
                tickcount += 3
            case .PLP:
                SP += 1
                F = memory[0x100 + Int(SP)]
                tickcount += 4
            default:
                fatalError("Unimplemented opcode")
            }
            if ticks > 0 && tickcount >= startTicks + ticks { break }
        }
    }
}

