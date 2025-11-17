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
            case .LDA_Immediate:
                A = nextByte()
                updateNZFlagsFor(newValue: A)
                tickcount += 2
            case .LDA_ZeroPage:
                A = memory[Int(nextByte())]
                updateNZFlagsFor(newValue: A)
                tickcount += 3
            case .LDA_ZeroPageX:
                A = memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .LDA_Absolute:
                A = memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .LDA_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, X)
                A = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .LDA_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, Y)
                A = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .LDA_IndirectX:
                let zeroPageAddress = nextByte()
                A = valueFrom(
                    zeroPageAddress: zeroPageAddress,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .LDA_IndirectY:
                let zeroPageAddress = nextByte()
                A = valueFrom(
                    zeroPageAddress: zeroPageAddress,
                    zeroPageOffet: 0,
                    targetOffset: Y,
                    incrementTickcountIfPageBoundaryCrossed: true
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 5
                
            case .LDX_Immediate:
                X = nextByte()
                updateNZFlagsFor(newValue: X)
                tickcount += 2
            case .LDX_ZeroPage:
                X = memory[Int(nextByte())]
                updateNZFlagsFor(newValue: X)
                tickcount += 3
            case .LDX_ZeroPageY:
                X = memory[Int(addingSignedByte(UInt16(nextByte()), Y))]
                updateNZFlagsFor(newValue: X)
                tickcount += 4
            case .LDX_Absolute:
                X = memory[Int(nextWord())]
                updateNZFlagsFor(newValue: X)
                tickcount += 4
            case .LDX_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, Y)
                X = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: X)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 0 : 1
                tickcount += 4
                
            case .LDY_Immediate:
                Y = nextByte()
                updateNZFlagsFor(newValue: Y)
                tickcount += 2
            case .LDY_ZeroPage:
                Y = memory[Int(nextByte())]
                updateNZFlagsFor(newValue: Y)
                tickcount += 3
            case .LDY_ZeroPageX:
                Y = memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: Y)
                tickcount += 4
            case .LDY_Absolute:
                Y = memory[Int(nextWord())]
                updateNZFlagsFor(newValue: Y)
                tickcount += 4
            case .LDY_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, X)
                Y = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: Y)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 0 : 1
                tickcount += 4
                
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
                
                // MARK: Branches
            case .BCC:
                branchOnClear(flag: .C)
            case .BCS:
                branchOnSet(flag: .C)
            case .BEQ:
                branchOnSet(flag: .Z)
            case .BNE:
                branchOnClear(flag: .Z)
            case .BMI:
                branchOnSet(flag: .N)
            case .BPL:
                branchOnClear(flag: .N)
            case .BVC:
                branchOnClear(flag: .V, advanceTickcountOnPageChange: false)
            case .BVS:
                branchOnSet(flag: .V)
                
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
                
                // MARK: Bitwise
                // All the bitwise operations work with A and the operand storing the result in A.
                
                // AND
            case .AND_Immediate:
                A = A & nextByte()
                updateNZFlagsFor(newValue: A)
                tickcount += 2
            case .AND_ZeroPage:
                A = A & memory[Int(nextByte())]
                updateNZFlagsFor(newValue: A)
                tickcount += 3
            case .AND_ZeroPageX:
                A = A & memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .AND_Absolute:
                A = A & memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .AND_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, X)
                A = A & memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .AND_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, Y)
                A = A & memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .AND_IndirectX:
                let zeroPageBase = nextByte()
                A = A & valueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .AND_IndirectY:
                let zeroPageBase = nextByte()
                A = A & valueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: 0,
                    targetOffset: Y,
                    incrementTickcountIfPageBoundaryCrossed: true
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 5
                
                // OR
            case .ORA_Immediate:
                A = A | nextByte()
                updateNZFlagsFor(newValue: A)
                tickcount += 2
            case .ORA_ZeroPage:
                A = A | memory[Int(nextByte())]
                updateNZFlagsFor(newValue: A)
                tickcount += 3
            case .ORA_ZeroPageX:
                A = A | memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .ORA_Absolute:
                A = A | memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .ORA_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, X)
                A = A | memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .ORA_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, Y)
                A = A | memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .ORA_IndirectX:
                let zeroPageBase = nextByte()
                A = A | valueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .ORA_IndirectY:
                let zeroPageBase = nextByte()
                A = A | valueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: 0,
                    targetOffset: Y,
                    incrementTickcountIfPageBoundaryCrossed: true
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 5
                
                // XOR
            case .EOR_Immediate:
                A = A ^ nextByte()
                updateNZFlagsFor(newValue: A)
                tickcount += 2
            case .EOR_ZeroPage:
                A = A ^ memory[Int(nextByte())]
                updateNZFlagsFor(newValue: A)
                tickcount += 3
            case .EOR_ZeroPageX:
                A = A ^ memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .EOR_Absolute:
                A = A ^ memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .EOR_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, X)
                A = A ^ memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .EOR_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addingSignedByte(baseAddress, Y)
                A = A ^ memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .EOR_IndirectX:
                let zeroPageBase = nextByte()
                A = A ^ valueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .EOR_IndirectY:
                let zeroPageBase = nextByte()
                A = A ^ valueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: 0,
                    targetOffset: Y,
                    incrementTickcountIfPageBoundaryCrossed: true
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 5
                
                // MARK: Compare
                // CMP A
            case .CMP_Immediate:
                let value = nextByte()
                compare(value, withRegister: A)
                tickcount += 2
            case .CMP_ZeroPage:
                let value = memory[Int(nextByte())]
                compare(value, withRegister: A)
                tickcount += 3
            case .CMP_ZeroPageX:
                let address = addingSignedByte(UInt16(nextByte()), X)
                let value = memory[Int(address)]
                compare(value, withRegister: A)
                tickcount += 4
            case .CMP_Absolute:
                let value = memory[Int(nextWord())]
                compare(value, withRegister: A)
                tickcount += 4
            case .CMP_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddesss = addingSignedByte(baseAddress, X)
                let value = memory[Int(targetAddesss)]
                compare(value, withRegister: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddesss) ? 4 : 5
            case .CMP_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddesss = addingSignedByte(baseAddress, Y)
                let value = memory[Int(targetAddesss)]
                compare(value, withRegister: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddesss) ? 4 : 5
            case .CMP_IndirectX:
                let value = valueFrom(
                    zeroPageAddress: nextByte(),
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                compare(value, withRegister: A)
                tickcount += 5
            case .CMP_IndirectY:
                let value = valueFrom(
                    zeroPageAddress: nextByte(),
                    zeroPageOffet: 0,
                    targetOffset: Y,
                    incrementTickcountIfPageBoundaryCrossed: true
                )
                compare(value, withRegister: A)
                tickcount +=  5
                // CMP X
            case .CPX_Immediate:
                let value = nextByte()
                compare(value, withRegister: X)
                tickcount += 2
            case .CPX_ZeroPage:
                let value = memory[Int(nextByte())]
                compare(value, withRegister: X)
                tickcount += 3
            case .CPX_Absolute:
                let value = memory[Int(nextWord())]
                compare(value, withRegister: X)
                tickcount += 4
                
                // CMP Y
            case .CPY_Immediate:
                let value = nextByte()
                compare(value, withRegister: Y)
                tickcount += 2
            case .CPY_ZeroPage:
                let value = memory[Int(nextByte())]
                compare(value, withRegister: Y)
                tickcount += 3
            case .CPY_Absolute:
                let value = memory[Int(nextWord())]
                compare(value, withRegister: Y)
                tickcount += 4
                
                // MARK: Stores
            case .STA_ZeroPage:
                A = memory[Int(nextByte())]
                tickcount += 3
            case .STA_ZeroPageX:
                A = memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                tickcount += 4
            case .STA_Absolute:
                A = memory[Int(nextWord())]
                tickcount += 4
            case .STA_AbsoluteX:
                A = memory[Int(addingSignedByte(nextWord(), X))]
                tickcount += 5
            case .STA_AbsoluteY:
                A = memory[Int(addingSignedByte(nextWord(), Y))]
                tickcount += 5
            case .STA_IndirectX:
                A = valueFrom(zeroPageAddress: nextByte(), zeroPageOffet: X, targetOffset: 0, incrementTickcountIfPageBoundaryCrossed: false)
                tickcount += 6
            case .STA_IndirectY:
                A = valueFrom(zeroPageAddress: nextByte(), zeroPageOffet: 0, targetOffset: Y, incrementTickcountIfPageBoundaryCrossed: false)
                tickcount += 6
                
            case .STX_ZeroPage:
                X = memory[Int(nextByte())]
                tickcount += 3
            case .STX_ZeroPageY:
                X = memory[Int(addingSignedByte(UInt16(nextByte()), Y))]
                tickcount += 4
            case .STX_Absolute:
                X = memory[Int(nextWord())]
                tickcount += 4
                
            case .STY_ZeroPage:
                tickcount += 3
                Y = memory[Int(nextByte())]
            case .STY_ZeroPageX:
                Y = memory[Int(addingSignedByte(UInt16(nextByte()), X))]
                tickcount += 4
            case .STY_Absolute:
                Y = memory[Int(nextWord())]
                tickcount += 4
                
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
                
            case .BIT_ZeroPage:
                let value = memory[Int(nextByte())]
                
                let Z = (value & A) == 0
                let N = (value & 0x80) != 0
                let V = (value & 0x40) != 0
                
                Z ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                N ? setFlag(flag: .N) : clearFlag(flag: .N)
                V ? setFlag(flag: .V) : clearFlag(flag: .V)
                
                tickcount += 3
            case .BIT_Absolute:
                let value = memory[Int(nextWord())]
                
                let Z = (value & A) == 0
                let N = (value & 0x80) != 0
                let V = (value & 0x40) != 0
                
                Z ? setFlag(flag: .Z) : clearFlag(flag: .Z)
                N ? setFlag(flag: .N) : clearFlag(flag: .N)
                V ? setFlag(flag: .V) : clearFlag(flag: .V)
                tickcount += 4
            default:
                fatalError("Unimplemented opcode")
            }
            if ticks > 0 && tickcount >= startTicks + ticks { break }
        }
    }
}

