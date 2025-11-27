//
//  Swift6502+ExecuteUtils.swift
//  Swift6502
//
//  Created by James Weatherley on 14/11/2025.
//

extension CPU6502 {
    
    // MARK: Utilities
    internal func updateNZFlagsFor(newValue: UInt8) {
        (newValue == 0) ? setFlag(.Z) : clearFlag(.Z)
        (newValue & 0x80 != 0) ? setFlag(.N) : clearFlag(.N)
    }
    
    // MARK: Shifts
    internal func LeftShiftShared(address: Int, rotate: Bool) {
        let byte = memory[Int(address)]
        
        let oldCarry: UInt8 = readFlag(.C) ? 1 : 0
        let newCarry = (byte & 0x80) != 0
        let newByte = (byte << 1) | oldCarry
        
        writeByte(addr: Int(address), value: newByte)
        updateNZFlagsFor(newValue: newByte)
        newCarry ? setFlag(.C) : clearFlag(.C)
    }
    
    internal func RightShiftShared(address: Int, rotate: Bool) {
        let byte = memory[Int(address)]
        
        let oldCarry: UInt8 = readFlag(.C) ? 0x80 : 0
        let newCarry = (byte & 0x01) != 0
        let newByte = (byte >> 1) | oldCarry
        
        writeByte(addr: Int(address), value: newByte)
        updateNZFlagsFor(newValue: newByte)
        newCarry ? setFlag(.C) : clearFlag(.C)
    }
    
    // MARK: Indirect addressing helper
    
    /// Bit of a messy function, but at least it keeps the mess in one place.
    /// (zeroPageAddress + zeroPageOffet) and (zeroPageAddress + zeroPageOffset + 1) contain another address in memory - the target.
    /// Typically either zeroPageOffet or targetOffset may be set, but not both.
    ///
    ///     zeroPageAddress:    Base address in the ZeroPage
    ///     zeroPageOffset:     Offset form zeroPageAddress - typically comes from X
    ///     targetOffset:       Offset form target (see comments above) - typically comes from Y
    ///     incrementTickcountIfPageBoundaryCrossed:    If true and target + target crosses a page boundary then add one to tickcount
    ///
    internal func readValueFrom(
        zeroPageAddress: UInt8,
        zeroPageOffet: UInt8,
        targetOffset: UInt8,
        incrementTickcountIfPageBoundaryCrossed: Bool
    ) -> UInt8 {
        let offsetZeroPageAddress = addSignedByte(UInt16(zeroPageAddress), zeroPageOffet)
        let loByte = memory[Int(offsetZeroPageAddress)]
        let hiByte = memory[Int(offsetZeroPageAddress + 1)]
        let targetAddress = (UInt16(hiByte) << 8) | (UInt16(loByte))
        let offsetTargetAddress = addSignedByte(targetAddress, targetOffset)
        if incrementTickcountIfPageBoundaryCrossed {
            tickcount +=  samePage(address1: targetAddress, address2: offsetTargetAddress) ? 0 : 1
        }
        return memory[Int(offsetTargetAddress)]
    }
    
    internal func writeValueTo(
        value: UInt8,
        zeroPageAddress: UInt8,
        zeroPageOffet: UInt8,
        targetOffset: UInt8
    ) {
        let offsetZeroPageAddress = addSignedByte(UInt16(zeroPageAddress), zeroPageOffet)
        let loByte = memory[Int(offsetZeroPageAddress)]
        let hiByte = memory[Int(offsetZeroPageAddress + 1)]
        let targetAddress = (UInt16(hiByte) << 8) | (UInt16(loByte))
        let offsetTargetAddress = addSignedByte(targetAddress, targetOffset)

        return memory[Int(offsetTargetAddress)] = value
    }

    /// Are address1 and address2 on the same page, where a page is a block of 100 bytes.
    /// Page 1: 0x0000 -> 0x00FF
    /// Page 2: 0x0100 -> 0x01FF
    /// Page 3: 0x0200 -> 0x02FF
    /// etc.
    internal func samePage(address1: UInt16, address2: UInt16) -> Bool {
        address1 & 0x100 == address2 & 0x100
    }
    
    // MARK: Adds and subtracts
    /// Performs ad addition of deltaUnsigned to base where deltaUnsigned is treated as a signed quantiy. e.g.:
    ///   0x200 + 0x33 -> 0x233
    ///   0x 200 + 0xFF -> 0x1FF
    internal func addSignedByte(_ base: UInt16, _ deltaUnsigned: UInt8) -> UInt16 {
        let deltaSigned = Int8(bitPattern: deltaUnsigned)
        let sumSigned = Int16(bitPattern: base) &+ Int16(deltaSigned)
        return UInt16(bitPattern: sumSigned)
    }
    
    /// Treats the arguments as BCD and returns a BCD value.
    /// num0 == 0x15, num1 == 0x28 would return 0x43 and not 0x3D as a normal hex addition would yield.
    /// Any value with any nibble with a value between A-F is undefined behaviour.
    ///
    ///  There is some guidance on the undefined behaviour here: http://www.6502.org/tutorials/decimal_mode.html#A
    ///  For the time being at least this implementation willl just do something undefined.
    ///
    /// From: http://www.6502.org/tutorials/decimal_mode.html#3.2.1
    /// • When the carry is clear, ADC NUM performs the calculation A = A + NUM
    /// • When the carry is set, ADC NUM performs the calculation A = A + NUM + 1
    ///
    ///  Prerequisite: D flag is set, all nibbles of num0 and num1 are in the range 0-9. Anything in A-F will lead to undefined behaviour.
    ///  Side effects: N, Z, C flags are set appropriately. V's behaviour is undefined for decimal mode. This implementation ignores it., 0x9)
    internal func addDecimal(_ num0: UInt8, to num1: UInt8) -> UInt8 {
        assert(readFlag(.D), "Called addDecimal() in hex mode")
        
        // Pull illegal values A-F down to 9.
        let loByte0 = min(num0 & 0x0F, 0x9)
        let hiByte0 = min((num0 & 0xF0) >> 4, 0x9)
        let loByte1 = min(num1 & 0x0F, 0x9)
        let hiByte1 = min((num1 & 0xF0) >> 4, 0x9)
        
        var internalCarry: UInt16 = 0
        var loByteResult = UInt16(loByte0) + UInt16(loByte1) + UInt16(readFlag(.C) ? 1 : 0)
        if loByteResult > 0x09 {
            loByteResult -= 0x0A
            internalCarry = 1
        }
        
        var hiByteResult = UInt16(hiByte0) + UInt16(hiByte1) + internalCarry
        if hiByteResult > 0x09 {
            hiByteResult -= 0x0A
            setFlag(.C)
        } else {
            clearFlag(.C)
        }
        
        let result = UInt8((hiByteResult << 0x4) | loByteResult)
        updateNZFlagsFor(newValue: result)
        return result
    }
    
    /// Same as addDecimal, including undefined behaviour handling, but performs subtraction.
    ///
    /// From: http://www.6502.org/tutorials/decimal_mode.html#3.2.1
    /// • When the carry is clear, SBC NUM performs the calculation A = A - NUM - 1
    /// • When the carry is set, SBC NUM performs the calculation A = A - NUM
    /// 
    ///  Prerequisite: D flag is set, all nibbles of num0 and num1 are in the range 0-9. Anything in A-F will lead to undefined behaviour.
    ///  Side effects: N, Z, C flags are set appropriately. V's behaviour is undefined for decimal mode. This implementation ignores it.
    internal func subtractDecimal(_ num0: UInt8, from num1: UInt8) -> UInt8 {
        assert(readFlag(.D), "Called subtractDecimal() in hex mode")
        
        // Pull illegal values A-F down to 9.
        let loByte0 = min(num0 & 0x0F, 0x9)
        let hiByte0 = min((num0 & 0xF0) >> 4, 0x9)
        let loByte1 = min(num1 & 0x0F, 0x9)
        let hiByte1 = min((num1 & 0xF0) >> 4, 0x9)
        
        var internalCarry: Int16 = 0
        var loByteResult = Int16(loByte1) - Int16(loByte0) - Int16(readFlag(.C) ? 0 : 1)
        if loByteResult < 0x0 {
            loByteResult += 0xA
            internalCarry = 1
        }
        
        var hiByteResult = Int16(hiByte1) - Int16(hiByte0) - internalCarry
        if hiByteResult < 0x0 {
            hiByteResult += 0xA
            setFlag(.C)
        } else {
            clearFlag(.C)
        }
        
        let result = UInt8((hiByteResult << 0x4) | loByteResult)
        updateNZFlagsFor(newValue: result)
        return result
    }
    
    /// The hex add and subtract functions are simpler than their decimal counterparts.
    /// They mostly concern themselves with setting the N, Z, C and V flags.
    ///
    /// Prerequisite: D flag is clear.
    /// Side effects: N, Z, C, V  flags are set appropriately.
    internal func addHex(_ num0: UInt8, to num1: UInt8) -> UInt8 {
        assert(!readFlag(.D), "Called addHex() in decimal mode")

        let result = num0 &+ num1 &+ (readFlag(.C) ? 1 : 0)
        updateNZFlagsFor(newValue: result)
        
        if UInt16(num0) + UInt16(num1) + (readFlag(.C) ? 1 : 0) > 0xFF {
            setFlag(.C)
        } else {
            clearFlag(.C)
        }
        
        // The logic sets V if adding two numbers with the same sign bit produces a result with a different sign bit.
        // e.g. 0xFF + 0xFF = 0xFE then V is clear and C is set.
        //      0xFF + 0x02 = 0x01 then V and C are set.
        if (num0 ^ result) & (num1 ^ result) & 0x80 != 0 {
            setFlag(.V)
        } else {
            clearFlag(.V)
        }
        
        return result
    }
    
    /// The hex add and subtract functions are simpler than their decimal counterparts.
    /// They mostly concern themselves with setting the N, Z, C and V flags.
    ///
    /// Prerequisite: D flag is clear.
    /// Side effects: N, Z, C, V  flags are set appropriately.
    internal func subtractHex(_ num0: UInt8, from num1: UInt8) -> UInt8 {
        assert(!readFlag(.D), "Called subtractHex() in decimal mode")

        let result = num1 &- num0 &- (readFlag(.C) ? 0 : 1)
        updateNZFlagsFor(newValue: result)
        
        // Compare Result    N    Z    C
        // num1 < num0       *    0    0
        // num1 = num0       0    1    1
        // num1 > num0       *    0    1
        //
        // N (and Z) based on num1 - num0
        if Int16(num1) - Int16(num0) &- (readFlag(.C) ? 0 : 1) < 0 {
            clearFlag(.C)
        } else {
            setFlag(.C)
        }
        
        // The logic sets V if subtracting numbers with different signs yields a result whose sign indicates wrap.
        // e.g. 0x00 - 0x01 = 0xFE then V is clear and C are set.
        //      0x80 - 0x01 = 0x7F then V is clear and C is clear.
        if (num1 ^ result) & (num1 ^ num0) & 0x80 != 0 {
            setFlag(.V)
        } else {
            clearFlag(.V)
        }
        
        return result
    }
    
    // MARK: Branch and compare
    internal func branchOnSet(flag: Flags) {
        branch(flag: flag, branchIfSet: true)
    }
    
    internal func branchOnClear(flag: Flags, advanceTickcountOnPageChange: Bool = true) {
        branch(flag: flag, branchIfSet: false, advanceTickcountOnPageChange: advanceTickcountOnPageChange)
    }
    
    /// Side effect: modifies tickcount and PC.
    internal func branch(flag: Flags, branchIfSet: Bool, advanceTickcountOnPageChange: Bool = true) {
        let delta = nextByte()
        tickcount += 2
        let branch = branchIfSet ? readFlag(flag) : !readFlag(flag)
        if branch {
            let target = addSignedByte(PC, delta)
            if !samePage(address1: PC, address2: target) {
                if advanceTickcountOnPageChange {
                    tickcount += 1
                }
            }
            PC = target
            tickcount += 1
        }
    }

    internal func compare(_ memory: UInt8, withRegister register: UInt8) {
        
        // Compare Result    N    Z    C
        // Reg < Memory      *    0    0
        // Reg = Memory      0    1    1
        // Reg > Memory      *    0    1
        //
        // N (and Z) based on Reg - Memory
        
        let subtraction = register &- memory
        updateNZFlagsFor(newValue: subtraction)
        register < memory ? clearFlag(.C) : setFlag(.C)
    }
}
