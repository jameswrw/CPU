//
//  Opcodes.swift
//  CPU
//
//  Created by James Weatherley on 29/10/2025.
//

public enum Opcodes6502: UInt8 {
    
    // MARK: Load
    case LDA_Immediate = 0xA9       // Test added
    case LDA_ZeroPage = 0xA5
    case LDA_ZeroPageX = 0xB5
    case LDA_Absolute = 0xAD
    case LDA_AbsoluteX = 0xBD
    case LDA_AbsoluteY = 0xB9
    case LDA_IndirectX = 0xA1
    case LDA_IndirectY = 0xB1
    
    case LDX_Immediate = 0xA2
    case LDX_ZeroPage = 0xA6
    case LDX_ZeroPageY = 0xB6
    case LDX_Absolute = 0xAE
    case LDX_AbsoluteY = 0xBE
    
    case LDY_Immediate = 0xA0
    case LDY_ZeroPage = 0xA4
    case LDY_ZeroPageX = 0xB4
    case LDY_Absolute = 0xAC
    case LDY_AbsoluteX = 0xBC
    
    // MARK: Increment
    case INC_ZeroPage = 0xE6
    case INC_ZeroPageX = 0xF6
    case INC_Absolute = 0xEE
    case INC_AbsoluteX = 0xFE
    case INX = 0xE8                 // Test Added
    case INY = 0xC8                 // Test Added
    
    // MARK: Decrement
    case DEC_ZeroPage = 0xC6
    case DEC_ZeroPageX = 0xD6
    case DEC_Absolute = 0xCE
    case DEC_AbsoluteX = 0xDE
    case DEX = 0xCA                 // Test Added
    case DEY = 0x88                 // Test Added
    
    // MARK: Store
    case STA_ZeroPage = 0x85
    case STA_ZeroPageX = 0x95
    case STA_Absolute = 0x8D
    case STA_AbsoluteX = 0x9D
    case STA_AbsoluteY = 0x99
    case STA_IndirectX = 0x81
    case STA_IndirectY = 0x91
    
    case STX_ZeroPage = 0x86
    case STX_ZeroPageY = 0x96
    case STX_Absolute = 0x8E
    
    case STY_ZeroPage = 0x84
    case STY_ZeroPageX = 0x94
    case STY_Absolute = 0x8C

    // MARK: Transfer
    case TAX = 0xAA                 // Test added
    case TAY = 0xA8                 // Test added
    case TSX = 0xBA                 // Test added
    case TXA = 0x8A                 // Test added
    case TXS = 0x9A                 // Test added
    case TYA = 0x98                 // Test added

    // MARK: Push and pull
    case PHA = 0x48                 // Test added
    case PHP = 0x08                 // Test added
    case PLA = 0x68                 // Test added
    case PLP = 0x28                 // Test added
    
    // MARK: Jump
    case JMP_Absolute = 0x4C        // Test added
    case JMP_Indirect = 0x6C        // Test added
    
    case JSR = 0x20
    case RTS = 0x60
    
    // MARK: Add with carry
    case ADC_Immediate = 0x69
    case ADC_ZeroPage = 0x65
    case ADC_ZeroPageX = 0x75
    case ADC_Absolute = 0x6D
    case ADC_AbsoluteX = 0x7D
    case ADC_AbsoluteY = 0x79
    case ADC_IndirectX = 0x61
    case ADC_IndirectY = 0x71
    
    // MARK: Subtract with carry
    case SBC_Immidiate = 0xE9
    case SBC_ZeroPage = 0xE5
    case SBC_ZeroPageX = 0xF5
    case SBC_Absolute = 0xED
    case SBC_AbsoluteX = 0xFD
    case SBC_AbsoluteY = 0xF9
    case SBC_IndirectX = 0xE1
    case SBC_IndirectY = 0xF1
    
    // MARK: Logical operations
    case AND_Immediate = 0x29
    case AND_ZeroPage = 0x25
    case AND_ZeroPageX = 0x35
    case AND_Absolute = 0x2D
    case AND_AbsoluteX = 0x3D
    case AND_AbsoluteY = 0x39
    case AND_IndirectX = 0x21
    case AND_IndirectY = 0x31
    
    case ORA_Immediate = 0x09
    case ORA_ZeroPage = 0x05
    case ORA_ZeroPageX = 0x15
    case ORA_Absolute = 0x0D
    case ORA_AbsoluteX = 0x1D
    case ORA_AbsoluteY = 0x19
    case ORA_IndirectX = 0x01
    case ORA_IndirectY = 0x11
    
    case EOR_Immediate = 0x49
    case EOR_ZeroPage = 0x45
    case EOR_ZeroPageX = 0x55
    case EOR_Absolute = 0x4D
    case EOR_AbsoluteX = 0x5D
    case EOR_AbsoluteY = 0x59
    case EOR_IndirectX = 0x41
    case EOR_IndirectY = 0x51
    
    // MARK: Shifts and rotates
    case ASL_Accumulator = 0x0A
    case ASL_ZeroPage = 0x06
    case ASL_ZeroPageX = 0x16
    case ASL_Absolute = 0x0E
    case ASL_AbsoluteX = 0x1E
    
    case LSR_Accumulator = 0x4A
    case LSR_ZeroPage = 0x46
    case LSR_ZeroPageX = 0x56
    case LSR_Absolute = 0x4E
    case LSR_AbsoluteX = 0x5E
    
    case ROL_Accumulator = 0x2A
    case ROL_ZeroPage = 0x26
    case ROL_ZeroPageX = 0x36
    case ROL_Absolute = 0x2E
    case ROL_AbsoluteX = 0x3E
    
    case ROR_Accumulator = 0x6A
    case ROR_ZeroPage = 0x66
    case ROR_ZeroPageX = 0x76
    case ROR_Absolute = 0x6E
    case ROR_AbsoluteX = 0x7E
    
    // MARK: Branch
    case BCC = 0x90
    case BCS = 0xB0
    case BEQ = 0xF0
    case BMI = 0x30
    case BNE = 0xD0
    case BPL = 0x10
    case BVC = 0x50
    case BVS = 0x70
    
    // MARK: Compare
    case CMP_Immediate = 0xC9
    case CMP_ZeroPage = 0xC5
    case CMP_ZeroPageX = 0xD5
    case CMP_Absolute = 0xCD
    case CMP_AbsoluteX = 0xDD
    case CMP_AbsoluteY = 0xD9
    case CMP_IndirectX = 0xC1
    case CMP_IndirectY = 0xD1
    
    case CPX_Immediate = 0xE0
    case CPX_ZeroPage = 0xE4
    case CPX_Absolute = 0xEC
  
    case CPY_Immediate = 0xC0
    case CPY_ZeroPage = 0xC4
    case CPY_Absolute = 0xCC
    
    // MARK: Clear flags
    case CLC = 0x18
    case CLD = 0xD8
    case CLI = 0x58
    case CLV = 0xB8
    
    // MARK: Set flags
    case SEC = 0x38
    case SED = 0xF8
    case SEI = 0x78
    
    // MARK: Misc.
    case BRK = 0x00
    case NOP = 0xEA
    case BIT_ZeroPage = 0x24
    case BIT_Absolute = 0x2C
    case RTI = 0x40
}
