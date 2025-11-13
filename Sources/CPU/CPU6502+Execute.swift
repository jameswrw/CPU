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
                updateNZFlagsFor(newValue: A)
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
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 5
            case .INC_ZeroPageX:
                let address = nextByte() &+ X
                memory[Int(address)] &+= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .INC_Absolute:
                let address = nextWord()
                memory[Int(address)] &+= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .INC_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                memory[Int(address)] &+= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 7
                
            // MARK: Decrement memory locations
            case .DEC_ZeroPage:
                let address = nextByte()
                memory[Int(address)] &-= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 5
            case .DEC_ZeroPageX:
                let address = nextByte() &+ X
                memory[Int(address)] &-= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .DEC_Absolute:
                let address = nextWord()
                memory[Int(address)] &-= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
                tickcount += 6
            case .DEC_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                memory[Int(address)] &-= 1
                updateNZFlagsFor(newValue: memory[Int(address)])
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
                updateNZFlagsFor(newValue: X)
                tickcount += 2
            case .TXA:
                A = X
                updateNZFlagsFor(newValue: A)
                tickcount += 2
            case .TAY:
                Y = A
                updateNZFlagsFor(newValue: Y)
                tickcount += 2
            case .TYA:
                A = Y
                updateNZFlagsFor(newValue: A)
                tickcount += 2
               
            // MARK: Increment and decrement X and Y
            case .INX:
                X &+= 1
                updateNZFlagsFor(newValue: X)
                tickcount += 2
            case .DEX:
                X &-= 1
                updateNZFlagsFor(newValue: X)
                tickcount += 2
            case .INY:
                Y &+= 1
                updateNZFlagsFor(newValue: Y)
                tickcount += 2
            case .DEY:
                Y &-= 1
                updateNZFlagsFor(newValue: Y)
                tickcount += 2
                
            // MARK: Shifts and rotates
            case .ASL_Accumulator:
                let msb = A & 0x80
                let newValue = A << 1
                A = newValue
                updateNZFlagsFor(newValue: A)
                (msb != 0) ? setFlag(flag: .C) : clearFlag(flag: .C)
                tickcount += 2
            case .ASL_ZeroPage:
                let address = nextByte()
                LeftShiftShared(address: Int(address), rotate: false)
                tickcount += 5
            case .ASL_ZeroPageX:
                let address = nextByte() &+ X
                LeftShiftShared(address: Int(address), rotate: false)
                tickcount += 6
            case .ASL_Absolute:
                let address = nextWord()
                LeftShiftShared(address: Int(address), rotate: false)
                tickcount += 6
            case .ASL_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                LeftShiftShared(address: Int(address), rotate: false)
                tickcount += 7
                
            case .LSR_Accumulator:
                let lsb = A & 0x01
                let newValue = A >> 1
                A = newValue
                updateNZFlagsFor(newValue: A)
                (lsb != 0) ? setFlag(flag: .C) : clearFlag(flag: .C)
                tickcount += 2
            case .LSR_ZeroPage:
                let address = nextByte()
                RightShiftShared(address: Int(address), rotate: false)
                tickcount += 5
            case .LSR_ZeroPageX:
                let address = nextByte() &+ X
                RightShiftShared(address: Int(address), rotate: false)
                tickcount += 6
            case .LSR_Absolute:
                let address = nextWord()
                RightShiftShared(address: Int(address), rotate: false)
                tickcount += 6
            case .LSR_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                RightShiftShared(address: Int(address), rotate: false)
                tickcount += 7
                
            case .ROL_Accumulator:
                let msb = A & 0x80
                let newValue = (A << 1) | (msb >> 7)
                A = newValue
                updateNZFlagsFor(newValue: A)
                (msb != 0) ? setFlag(flag: .C) : clearFlag(flag: .C)
                tickcount += 2
            case .ROL_ZeroPage:
                let address = nextByte()
                LeftShiftShared(address: Int(address), rotate: true)
                tickcount += 5
            case .ROL_ZeroPageX:
                let address = nextByte() &+ X
                LeftShiftShared(address: Int(address), rotate: true)
                tickcount += 6
            case .ROL_Absolute:
                let address = nextWord()
                LeftShiftShared(address: Int(address), rotate: true)
                tickcount += 6
            case .ROL_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                LeftShiftShared(address: Int(address), rotate: true)
                tickcount += 7
                
            case .ROR_Accumulator:
                let lsb = A & 0x01
                let newValue = (A >> 1) | (lsb << 7)
                A = newValue
                updateNZFlagsFor(newValue: A)
                (lsb != 0) ? setFlag(flag: .C) : clearFlag(flag: .C)
                tickcount += 2
            case .ROR_ZeroPage:
                let address = nextByte()
                RightShiftShared(address: Int(address), rotate: true)
                tickcount += 5
            case .ROR_ZeroPageX:
                let address = nextByte() &+ X
                RightShiftShared(address: Int(address), rotate: true)
                tickcount += 6
            case .ROR_Absolute:
                let address = nextWord()
                RightShiftShared(address: Int(address), rotate: true)
                tickcount += 6
            case .ROR_AbsoluteX:
                let address = nextWord() &+ UInt16(X)
                RightShiftShared(address: Int(address), rotate: true)
                tickcount += 7

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
    
            // MARK: Subroutines
            case .JSR:
                let target = nextWord()
                pushWord(PC - 1)
                PC = target
                tickcount += 6
            case .RTS:
                PC = popWord() + 1
                tickcount += 6
                
            // MARK: Misc
            case .NOP:
                tickcount += 2
                
            default:
                fatalError("Unimplemented opcode")
            }
            if ticks > 0 && tickcount >= startTicks + ticks { break }
        }
    }
    
    // MARK: Utilities
    fileprivate func updateNZFlagsFor(newValue: UInt8) {
        (newValue == 0) ? setFlag(flag: .Z) : clearFlag(flag: .Z)
        (newValue & 0x80 != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
    }
    
    fileprivate func LeftShiftShared(address: Int, rotate: Bool) {
        let byte = memory[Int(address)]
        let msb = byte & 0x80
        var newValue = byte << 1
        if rotate {
            newValue |= msb >> 7
        }
        writeByte(addr: Int(address), value: newValue)
        updateNZFlagsFor(newValue: newValue)
        (msb != 0) ? setFlag(flag: .C) : clearFlag(flag: .C)
    }
    
    fileprivate func RightShiftShared(address: Int, rotate: Bool) {
        let byte = memory[Int(address)]
        let lsb = byte & 0x01
        var newValue = byte >> 1
        if rotate {
            newValue |= lsb << 7
        }
        writeByte(addr: Int(address), value: newValue)
        updateNZFlagsFor(newValue: newValue)
        (lsb != 0) ? setFlag(flag: .C) : clearFlag(flag: .C)
    }

}

