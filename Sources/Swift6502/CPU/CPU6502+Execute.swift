//
//  Swift6502+Execute.swift
//  Swift6502
//
//  Created by James Weatherley on 30/10/2025.
//

import Foundation

public extension CPU6502 {
    
    // MARK: Interupts
    internal func requestIRQ() {
        waitingForIRQHandler = true
    }
    
    internal func requestNMI() {
        waitingForNMIHandler = true
    }

    internal func handleIRQ() {
        if !readFlag(.I) && !waitingForNMIHandler {
            waitingForIRQHandler = false
            pushWord(PC)
            pushByte(F)
            setFlag(.I)
            PC = readWord(addr: Int(irqVector))
            tickcount += 7
        }
    }
    
    internal func handleNMI() {
        waitingForNMIHandler = false
        pushWord(PC)
        pushByte(F)
        setFlag(.I)
        PC = readWord(addr: Int(nmiVector))
        tickcount += 6
    }
    
    // MARK: Reset and run
    func reset() {
        clearFlag(.C)
        clearFlag(.Z)
        clearFlag(.I)
        clearFlag(.D)
        clearFlag(.B)
        setFlag(.One)
        clearFlag(.V)
        clearFlag(.N)
        
        SP = 0xFF
        PC = 0xFFFC
        A = 0
        X = 0
        Y = 0
    }
    
    
    /// Run for the length of a frame. The idea being that clients call this in a loop - something like
    /// :
    ///    while true {
    ///        cpu.runForFrame(clockspeed: 1.0, fps: 50)
    ///        updateScreen()
    ///        performIO()
    ///        ...
    ///    }
    ///
    /// - Parameters:
    ///   - clockspeed: Clock speed in MHz
    ///   - fps: Screen refresh in Hz (50 for PAL, 60 for NTSC)
    func runForFrame(clockspeed: Double, fps: Int) {
        let ticksPerFrame = Int(ceil(clockspeed * 1_000_000 / Double(fps)))
        runForTicks(ticksPerFrame)
    }

    internal func runForTicks(_ ticks: Int) {
        let startTicks = tickcount
        
        while true {
            if waitingForNMIHandler {
                handleNMI()
            }
            if waitingForIRQHandler {
                handleIRQ()
            }
            
            switch nextOpcode() {
                // MARK: LDA
            case .LDA_Immediate:
                A = nextByte()
                updateNZFlagsFor(newValue: A)
                tickcount += 2
            case .LDA_ZeroPage:
                A = memory[Int(nextByte())]
                updateNZFlagsFor(newValue: A)
                tickcount += 3
            case .LDA_ZeroPageX:
                A = memory[Int(addSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .LDA_Absolute:
                A = memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .LDA_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, X)
                A = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .LDA_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, Y)
                A = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .LDA_IndirectX:
                let zeroPageAddress = nextByte()
                A = readValueFrom(
                    zeroPageAddress: zeroPageAddress,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .LDA_IndirectY:
                let zeroPageAddress = nextByte()
                A = readValueFrom(
                    zeroPageAddress: zeroPageAddress,
                    zeroPageOffet: 0,
                    targetOffset: Y,
                    incrementTickcountIfPageBoundaryCrossed: true
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 5
                
                // MARK: LDX
            case .LDX_Immediate:
                X = nextByte()
                updateNZFlagsFor(newValue: X)
                tickcount += 2
            case .LDX_ZeroPage:
                X = memory[Int(nextByte())]
                updateNZFlagsFor(newValue: X)
                tickcount += 3
            case .LDX_ZeroPageY:
                X = memory[Int(addSignedByte(UInt16(nextByte()), Y))]
                updateNZFlagsFor(newValue: X)
                tickcount += 4
            case .LDX_Absolute:
                X = memory[Int(nextWord())]
                updateNZFlagsFor(newValue: X)
                tickcount += 4
            case .LDX_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, Y)
                X = memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: X)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 0 : 1
                tickcount += 4
                
                // MARK: LDY
            case .LDY_Immediate:
                Y = nextByte()
                updateNZFlagsFor(newValue: Y)
                tickcount += 2
            case .LDY_ZeroPage:
                Y = memory[Int(nextByte())]
                updateNZFlagsFor(newValue: Y)
                tickcount += 3
            case .LDY_ZeroPageX:
                Y = memory[Int(addSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: Y)
                tickcount += 4
            case .LDY_Absolute:
                Y = memory[Int(nextWord())]
                updateNZFlagsFor(newValue: Y)
                tickcount += 4
            case .LDY_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, X)
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
                
                PC = readWord(addr: Int(nextWord()))
                tickcount += 5
                
                // MARK: Branches
                // branchOn*() functions will modify tickcount and PC.
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
                
                // MARK: Add with carry
                // From: http://www.6502.org/tutorials/decimal_mode.html#3.2.1
                // • When the carry is clear, ADC NUM performs the calculation A = A + NUM
                // • When the carry is set, ADC NUM performs the calculation A = A + NUM + 1
            case .ADC_Immediate:
                if readFlag(.D) {
                    A = addDecimal(nextByte(), to: A)
                } else {
                    A = addHex(nextByte(), to: A)
                }
                tickcount += 2
            case .ADC_ZeroPage:
                if readFlag(.D) {
                    A = addDecimal(memory[Int(nextByte())], to: A)
                } else {
                    A = addHex(memory[Int(nextByte())], to: A)
                }
                tickcount += 3
            case .ADC_ZeroPageX:
                if readFlag(.D) {
                    let address = nextByte() &+ X
                    A = addDecimal(memory[Int(address)], to: A)
                } else {
                    let address = nextByte() &+ X
                    A = addHex(memory[Int(address)], to: A)
                }
                tickcount += 4
            case .ADC_Absolute:
                if readFlag(.D) {
                    A = addDecimal(memory[Int(nextWord())], to: A)
                } else {
                    A = addHex(memory[Int(nextWord())], to: A)
                }
                tickcount += 4
            case .ADC_AbsoluteX:
                if readFlag(.D) {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, X)
                    A = addDecimal(memory[Int(targetAddress)], to: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                } else {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, X)
                    A = addHex(memory[Int(targetAddress)], to: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                }
                tickcount += 4
            case .ADC_AbsoluteY:
                if readFlag(.D) {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, Y)
                    A = addDecimal(memory[Int(targetAddress)], to: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                } else {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, Y)
                    A = addHex(memory[Int(targetAddress)], to: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                }
                tickcount += 4
            case .ADC_IndirectX:
                if readFlag(.D) {
                    let operand = readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: X,
                        targetOffset: 0,
                        incrementTickcountIfPageBoundaryCrossed: false
                    )
                    A = addDecimal(operand, to: A)
                } else {
                    let operand = readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: X,
                        targetOffset: 0,
                        incrementTickcountIfPageBoundaryCrossed: false
                    )
                    A = addHex(operand, to: A)
                }
                tickcount += 6
            case .ADC_IndirectY:
                if readFlag(.D) {
                    let operand =
                    readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: 0,
                        targetOffset: Y,
                        incrementTickcountIfPageBoundaryCrossed: true
                    )
                    A = addDecimal(operand, to: A)
                } else {
                    let operand =
                    readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: 0,
                        targetOffset: Y,
                        incrementTickcountIfPageBoundaryCrossed: true
                    )
                    A = addHex(operand, to: A)
                }
                tickcount += 5
                
                
                // MARK: Subtract with carry
                // From: http://www.6502.org/tutorials/decimal_mode.html#3.2.1
                // • When the carry is clear, SBC NUM performs the calculation A = A - NUM - 1
                // • When the carry is set, SBC NUM performs the calculation A = A - NUM
            case .SBC_Immediate:
                if readFlag(.D) {
                    A = subtractDecimal(nextByte(), from: A)
                } else {
                    A = subtractHex(nextByte(), from: A)
                }
                tickcount += 2
            case .SBC_ZeroPage:
                if readFlag(.D) {
                    A = subtractDecimal(memory[Int(nextByte())], from: A)
                } else {
                    A = subtractHex(memory[Int(nextByte())], from: A)
                }
                tickcount += 3
            case .SBC_ZeroPageX:
                if readFlag(.D) {
                    let address = nextByte() &+ X
                    A = subtractDecimal(memory[Int(address)], from: A)
                } else {
                    let address = nextByte() &+ X
                    A = subtractHex(memory[Int(address)], from: A)
                }
                tickcount += 4
            case .SBC_Absolute:
                if readFlag(.D) {
                    A = subtractDecimal(memory[Int(nextWord())], from: A)
                } else {
                    A = subtractHex(memory[Int(nextWord())], from: A)
                }
                tickcount += 4
            case .SBC_AbsoluteX:
                if readFlag(.D) {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, X)
                    A = subtractDecimal(memory[Int(targetAddress)], from: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                } else {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, X)
                    A = subtractHex(memory[Int(targetAddress)], from: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                }
                tickcount += 4
            case .SBC_AbsoluteY:
                if readFlag(.D) {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, Y)
                    A = subtractDecimal(memory[Int(targetAddress)], from: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                } else {
                    let baseAddress = nextWord()
                    let targetAddress = addSignedByte(baseAddress, Y)
                    A = subtractHex(memory[Int(targetAddress)], from: A)
                    if !samePage(address1: baseAddress, address2: targetAddress) {
                        tickcount += 1
                    }
                }
                tickcount += 4
            case .SBC_IndirectX:
                if readFlag(.D) {
                    let operand = readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: X,
                        targetOffset: 0,
                        incrementTickcountIfPageBoundaryCrossed: false
                    )
                    A = subtractDecimal(operand, from: A)
                } else {
                    let operand = readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: X,
                        targetOffset: 0,
                        incrementTickcountIfPageBoundaryCrossed: false
                    )
                    A = subtractHex(operand, from: A)
                }
                tickcount += 6
            case .SBC_IndirectY:
                if readFlag(.D) {
                    let operand = readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: 0,
                        targetOffset: Y,
                        incrementTickcountIfPageBoundaryCrossed: true
                    )
                    A = subtractDecimal(operand, from: A)
                } else {
                    let operand = readValueFrom(
                        zeroPageAddress: nextByte(),
                        zeroPageOffet: 0,
                        targetOffset: Y,
                        incrementTickcountIfPageBoundaryCrossed: true
                    )
                    A = subtractHex(operand, from: A)
                }
                tickcount += 5
                
                // MARK: Shifts and rotates
            case .ASL_Accumulator:
                let msb = A & 0x80
                let newValue = A << 1
                A = newValue
                updateNZFlagsFor(newValue: A)
                (msb != 0) ? setFlag(.C) : clearFlag(.C)
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
                (lsb != 0) ? setFlag(.C) : clearFlag(.C)
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
                (msb != 0) ? setFlag(.C) : clearFlag(.C)
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
                (lsb != 0) ? setFlag(.C) : clearFlag(.C)
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
                A = A & memory[Int(addSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .AND_Absolute:
                A = A & memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .AND_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, X)
                A = A & memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .AND_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, Y)
                A = A & memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .AND_IndirectX:
                let zeroPageBase = nextByte()
                A = A & readValueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .AND_IndirectY:
                let zeroPageBase = nextByte()
                A = A & readValueFrom(
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
                A = A | memory[Int(addSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .ORA_Absolute:
                A = A | memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .ORA_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, X)
                A = A | memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .ORA_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, Y)
                A = A | memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .ORA_IndirectX:
                let zeroPageBase = nextByte()
                A = A | readValueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .ORA_IndirectY:
                let zeroPageBase = nextByte()
                A = A | readValueFrom(
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
                A = A ^ memory[Int(addSignedByte(UInt16(nextByte()), X))]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .EOR_Absolute:
                A = A ^ memory[Int(nextWord())]
                updateNZFlagsFor(newValue: A)
                tickcount += 4
            case .EOR_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, X)
                A = A ^ memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .EOR_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddress = addSignedByte(baseAddress, Y)
                A = A ^ memory[Int(targetAddress)]
                updateNZFlagsFor(newValue: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddress) ? 4 : 5
            case .EOR_IndirectX:
                let zeroPageBase = nextByte()
                A = A ^ readValueFrom(
                    zeroPageAddress: zeroPageBase,
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                updateNZFlagsFor(newValue: A)
                tickcount += 6
            case .EOR_IndirectY:
                let zeroPageBase = nextByte()
                A = A ^ readValueFrom(
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
                let address = addSignedByte(UInt16(nextByte()), X)
                let value = memory[Int(address)]
                compare(value, withRegister: A)
                tickcount += 4
            case .CMP_Absolute:
                let value = memory[Int(nextWord())]
                compare(value, withRegister: A)
                tickcount += 4
            case .CMP_AbsoluteX:
                let baseAddress = nextWord()
                let targetAddesss = addSignedByte(baseAddress, X)
                let value = memory[Int(targetAddesss)]
                compare(value, withRegister: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddesss) ? 4 : 5
            case .CMP_AbsoluteY:
                let baseAddress = nextWord()
                let targetAddesss = addSignedByte(baseAddress, Y)
                let value = memory[Int(targetAddesss)]
                compare(value, withRegister: A)
                tickcount += samePage(address1: baseAddress, address2: targetAddesss) ? 4 : 5
            case .CMP_IndirectX:
                let value = readValueFrom(
                    zeroPageAddress: nextByte(),
                    zeroPageOffet: X,
                    targetOffset: 0,
                    incrementTickcountIfPageBoundaryCrossed: false
                )
                compare(value, withRegister: A)
                tickcount += 6
            case .CMP_IndirectY:
                let value = readValueFrom(
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
                memory[Int(nextByte())] = A
                tickcount += 3
            case .STA_ZeroPageX:
                memory[Int(addSignedByte(UInt16(nextByte()), X))] = A
                tickcount += 4
            case .STA_Absolute:
                memory[Int(nextWord())] = A
                tickcount += 4
            case .STA_AbsoluteX:
                memory[Int(addSignedByte(nextWord(), X))] = A
                tickcount += 5
            case .STA_AbsoluteY:
                memory[Int(addSignedByte(nextWord(), Y))] = A
                tickcount += 5
            case .STA_IndirectX:
                writeValueTo(
                    value: A,
                    zeroPageAddress: nextByte(),
                    zeroPageOffet: X,
                    targetOffset: 0,
                )
                tickcount += 6
            case .STA_IndirectY:
                writeValueTo(
                    value: A,
                    zeroPageAddress: nextByte(),
                    zeroPageOffet: 0,
                    targetOffset: Y
                )
                tickcount += 6
                
            case .STX_ZeroPage:
                memory[Int(nextByte())] = X
                tickcount += 3
            case .STX_ZeroPageY:
                memory[Int(addSignedByte(UInt16(nextByte()), Y))] = X
                tickcount += 4
            case .STX_Absolute:
                memory[Int(nextWord())] = X
                tickcount += 4
                
            case .STY_ZeroPage:
                tickcount += 3
                memory[Int(nextByte())] = Y
            case .STY_ZeroPageX:
                memory[Int(addSignedByte(UInt16(nextByte()), X))] = Y
                tickcount += 4
            case .STY_Absolute:
                memory[Int(nextWord())] = Y
                tickcount += 4
                
                // MARK: Clear flags
            case .CLC:
                clearFlag(.C)
                tickcount += 2
            case .CLD:
                clearFlag(.D)
                tickcount += 2
            case .CLI:
                clearFlag(.I)
                tickcount += 2
            case .CLV:
                clearFlag(.V)
                tickcount += 2
                
                // MARK: Set flags
            case .SEC:
                setFlag(.C)
                tickcount += 2
            case .SED:
                setFlag(.D)
                tickcount += 2
            case .SEI:
                setFlag(.I)
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
                
                Z ? setFlag(.Z) : clearFlag(.Z)
                N ? setFlag(.N) : clearFlag(.N)
                V ? setFlag(.V) : clearFlag(.V)
                
                tickcount += 3
            case .BIT_Absolute:
                let value = memory[Int(nextWord())]
                
                let Z = (value & A) == 0
                let N = (value & 0x80) != 0
                let V = (value & 0x40) != 0
                
                Z ? setFlag(.Z) : clearFlag(.Z)
                N ? setFlag(.N) : clearFlag(.N)
                V ? setFlag(.V) : clearFlag(.V)
                tickcount += 4
            case .BRK:
                PC &+= 1
                pushWord(PC)
                pushByte(F)
                setFlag(.I)
                PC = readWord(addr: Int(irqVector))
                tickcount += 7
            case .RTI:
                F = popByte()
                PC = popWord()
                tickcount += 6
            }
            if ticks > 0 && tickcount >= startTicks + ticks { break }
        }
    }
}

