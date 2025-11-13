//
//  CPU6502+Execute.swift
//  CPU
//
//  Created by James Weatherley on 30/10/2025.
//

public extension CPU6502 {
       
    // MARK: Reset and run
    func reset() {
        clearFlag(flag: .C)
        clearFlag(flag: .Z)
        clearFlag(flag: .I)
        clearFlag(flag: .D)
        clearFlag(flag: .B)
        setFlag(flag: .One)
        clearFlag(flag: .V)
        clearFlag(flag: .N)
        
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
                
            // MARK: LDAs
            case .LDA_Absolute:
                A = nextByte()
                updateFlagsFor(newValue: A)
                tickcount += 2
                
            // MARK: JMPs
            case .JMP_Absolute:
                PC = nextWord()
                tickcount += 3
            case .JMP_Indirect:
                // TODO: The following is not implemented.
                //
                // From: http://www.6502.org/tutorials/6502opcodes.html#INC
                // AN INDIRECT JUMP MUST NEVER USE A
                // VECTOR BEGINNING ON THE LAST BYTE
                // OF A PAGE
                // For example if address $3000 contains $40, $30FF contains $80, and $3100 contains $50, the result of JMP ($30FF) will be a transfer of control to $4080 rather than $5080 as you intended i.e. the 6502 took the low byte of the address from $30FF and the high byte from $3000.
                
                PC = readWord16(addr: Int(nextWord()))
                tickcount += 5
                
            // MARK: Increment memory locations
            case .INC_ZeroPage:
                let address = nextByte()
                memory[Int(address)] &+= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 5
            case .INC_ZeroPageX:
                let address = nextByte() &+ X
                memory[Int(address)] &+= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .INC_Absolute:
                let address = nextWord()
                memory[Int(address)] &+= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .INC_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                memory[Int(address)] &+= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 7
                
            // MARK: Decrement memory locations
            case .DEC_ZeroPage:
                let address = nextByte()
                memory[Int(address)] &-= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 5
            case .DEC_ZeroPageX:
                let address = nextByte() &+ X
                memory[Int(address)] &-= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .DEC_Absolute:
                let address = nextWord()
                memory[Int(address)] &-= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .DEC_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                memory[Int(address)] &-= 1
                updateFlagsFor(newValue: memory[Int(address)])
                tickcount += 7
                
            // MARK: Stack operations
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
                
            // MARK: Transfer between A, X and Y
            case .TAX:
                X = A
                updateFlagsFor(newValue: X)
                tickcount += 2
            case .TXA:
                A = X
                updateFlagsFor(newValue: A)
                tickcount += 2
            case .TAY:
                Y = A
                updateFlagsFor(newValue: Y)
                tickcount += 2
            case .TYA:
                A = Y
                updateFlagsFor(newValue: A)
                tickcount += 2
               
            // MARK: Incrememnt and decrement X and Y
            case .INX:
                X &+= 1
                updateFlagsFor(newValue: X)
                tickcount += 2
            case .DEX:
                X &-= 1
                updateFlagsFor(newValue: X)
                tickcount += 2
            case .INY:
                Y &+= 1
                updateFlagsFor(newValue: Y)
                tickcount += 2
            case .DEY:
                Y &-= 1
                updateFlagsFor(newValue: Y)
                tickcount += 2
                
            // MARK: Clear flags
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
                
            // MARK: Set flags
            case .SEC:
                setFlag(flag: .C)
                tickcount += 2
            case .SED:
                setFlag(flag: .D)
                tickcount += 2
            case .SEI:
                setFlag(flag: .I)
                tickcount += 2
                
            // MARK: Misc
            case .NOP:
                tickcount += 2
    
            // MARK: Subroutines
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
    
    // MARK: Utilities
    fileprivate func updateFlagsFor(newValue: UInt8) {
        (newValue == 0) ? setFlag(flag: .Z) : clearFlag(flag: .Z)
        (newValue & 0x80 != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
    }
}

