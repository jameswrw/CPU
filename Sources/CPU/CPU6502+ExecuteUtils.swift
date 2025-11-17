//
//  CPU6502+ExecuteUtils.swift
//  CPU
//
//  Created by James Weatherley on 14/11/2025.
//

extension CPU6502 {
    // MARK: Utilities
    internal func updateNZFlagsFor(newValue: UInt8) {
        (newValue == 0) ? setFlag(flag: .Z) : clearFlag(flag: .Z)
        (newValue & 0x80 != 0) ? setFlag(flag: .N) : clearFlag(flag: .N)
    }
    
    internal func LeftShiftShared(address: Int, rotate: Bool) {
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
    
    internal func RightShiftShared(address: Int, rotate: Bool) {
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
    
    /// Bit of a messy function, but at least it keeps the mess in one place.
    /// (zeroPageAddress + zeroPageOffet) and (zeroPageAddress + zeroPageOffset + 1) contain another address in memory - the target.
    /// Typically either zeroPageOffet or targetOffset may be set, but not both.
    ///
    ///     zeroPageAddress:    Base address in the ZeroPage
    ///     zeroPageOffset:     Offset form zeroPageAddress - typically comes from X
    ///     targetOffset:       Offset form target (see comments above) - typically comes from Y
    ///     incrementTickcountIfPageBoundaryCrossed:    If true and target + target crosses a page boundary then add one to tickcount
    ///
    internal func valueFrom(
        zeroPageAddress: UInt8,
        zeroPageOffet: UInt8,
        targetOffset: UInt8,
        incrementTickcountIfPageBoundaryCrossed: Bool
    ) -> UInt8 {
        let offsetZeroPageAddress = addingSignedByte(UInt16(zeroPageAddress), zeroPageOffet)
        let loByte = memory[Int(offsetZeroPageAddress)]
        let hiByte = memory[Int(offsetZeroPageAddress + 1)]
        let targetAddress = (UInt16(hiByte) << 8) | (UInt16(loByte))
        let offsetTargetAddress = addingSignedByte(targetAddress, targetOffset)
        if incrementTickcountIfPageBoundaryCrossed {
            tickcount +=  samePage(address1: targetAddress, address2: offsetTargetAddress) ? 0 : 1
        }
        return memory[Int(offsetTargetAddress)]
    }

    internal func addingSignedByte(_ base: UInt16, _ deltaUnsigned: UInt8) -> UInt16 {
        let deltaSigned = Int8(bitPattern: deltaUnsigned)
        let sumSigned = Int16(bitPattern: base) &+ Int16(deltaSigned)
        return UInt16(bitPattern: sumSigned)
    }
    
    internal func samePage(address1: UInt16, address2: UInt16) -> Bool {
        address1 & 0x100 == address2 & 0x100
    }
    
    internal func branchOnSet(flag: Flags) {
        branch(flag: flag, branchIfSet: true)
    }
    
    internal func branchOnClear(flag: Flags, advanceTickcountOnPageChange: Bool = true) {
        branch(flag: flag, branchIfSet: false, advanceTickcountOnPageChange: advanceTickcountOnPageChange)
    }
    
    internal func branch(flag: Flags, branchIfSet: Bool, advanceTickcountOnPageChange: Bool = true) {
        let delta = nextByte()
        tickcount += 2
        let branch = branchIfSet ? readFlag(flag: flag) : !readFlag(flag: flag)
        if branch {
            let target = addingSignedByte(PC, delta)
            if !samePage(address1: PC, address2: target) {
                if advanceTickcountOnPageChange {
                    tickcount += 1
                }
            }
            PC = target
            tickcount += 1
        }
    }

    internal func compare(_ value: UInt8, withRegister register: UInt8) {
        register >= value ? setFlag(flag: .C) : clearFlag(flag: .C)
        register == value ? setFlag(flag: .Z) : clearFlag(flag: .Z)
        (register & 0x80) != 0 ? setFlag(flag: .N) : clearFlag(flag: .N)
    }
}
