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
                A = nextByte()
                A == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (A & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .JMP_Absolute:
                PC = nextWord()
                tickcount += 3
            case .JMP_Indirect:
                PC = readWord16(addr: Int(nextWord()))
                tickcount += 5
            case .TXS:
                SP = X
                tickcount += 2
            case .TSX:
                X = SP
                tickcount += 2
            case .PHA:
                pushByte(A)
                tickcount += 3
            case .PLA:
                A = popByte()
                tickcount += 4
            case .PHP:
                pushByte(F)
                tickcount += 3
            case .PLP:
                F = popByte()
                tickcount += 4
            case .TAX:
                X = A
                X == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (X & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .TXA:
                A = X
                A == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (A & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .TAY:
                Y = A
                Y == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (Y & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .TYA:
                A = Y
                A == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (A & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .INX:
                X &+= 1
                X == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (X & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .DEX:
                X &-= 1
                X == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (X & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .INY:
                Y &+= 1
                Y == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (Y & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .DEY:
                Y &-= 1
                Y == 0 ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                (Y & 0x80  != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
                tickcount += 2
            case .CLC:
                clearFlag(flag: .C)
                tickcount += 2
            case .CLD:
                clearFlag(flag: .D)
                tickcount += 2
            case .CLI:
                clearFlag(flag: .I)
                tickcount += 2
            case .CLV:
                clearFlag(flag: .V)
                tickcount += 2
            case .SEC:
                setFlag(flag: .C)
                tickcount += 2
            case .SED:
                setFlag(flag: .D)
                tickcount += 2
            case .SEI:
                setFlag(flag: .I)
                tickcount += 2
            case .NOP:
                tickcount += 2
            case .JSR:
                let target = nextWord()
                pushWord(PC - 1)
                PC = target
                tickcount += 6
            case .RTS:
                PC = popWord() + 1
                tickcount += 6
            default:
                fatalError("Unimplemented opcode")
            }
            if ticks > 0 && tickcount >= startTicks + ticks { break }
        }
    }
}

