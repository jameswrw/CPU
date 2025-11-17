//
//  Opcodes.swift
//  CPU
//
//  Created by James Weatherley on 29/10/2025.
//

public enum Opcodes6502: UInt8 {
    
    // MARK: Load
    case LDA_Immediate = 0xA9       // Test added
    case LDA_ZeroPage = 0xA5        // Test added
    case LDA_ZeroPageX = 0xB5       // Test added
    case LDA_Absolute = 0xAD        // Test added
    case LDA_AbsoluteX = 0xBD       // Test added
    case LDA_AbsoluteY = 0xB9       // Test added
    case LDA_IndirectX = 0xA1       // Test added
    case LDA_IndirectY = 0xB1       // Test added
    
    case LDX_Immediate = 0xA2       // Test added
    case LDX_ZeroPage = 0xA6        // Test added
    case LDX_ZeroPageY = 0xB6       // Test added
    case LDX_Absolute = 0xAE        // Test added
    case LDX_AbsoluteY = 0xBE       // Test added
    
    case LDY_Immediate = 0xA0       // Test added
    case LDY_ZeroPage = 0xA4        // Test added
    case LDY_ZeroPageX = 0xB4       // Test added
    case LDY_Absolute = 0xAC        // Test added
    case LDY_AbsoluteX = 0xBC       // Test added
    
    // MARK: Increment
    case INC_ZeroPage = 0xE6        // Test added
    case INC_ZeroPageX = 0xF6       // Test added
    case INC_Absolute = 0xEE        // Test added
    case INC_AbsoluteX = 0xFE       // Test added
    case INX = 0xE8                 // Test Added
    case INY = 0xC8                 // Test Added
    
    // MARK: Decrement
    case DEC_ZeroPage = 0xC6        // Test Added
    case DEC_ZeroPageX = 0xD6       // Test Added
    case DEC_Absolute = 0xCE        // Test Added
    case DEC_AbsoluteX = 0xDE       // Test Added
    case DEX = 0xCA                 // Test Added
    case DEY = 0x88                 // Test Added
    
    // MARK: Store
    case STA_ZeroPage = 0x85        // Test Added
    case STA_ZeroPageX = 0x95       // Test Added
    case STA_Absolute = 0x8D        // Test Added
    case STA_AbsoluteX = 0x9D       // Test Added
    case STA_AbsoluteY = 0x99       // Test Added
    case STA_IndirectX = 0x81       // Test Added
    case STA_IndirectY = 0x91       // Test Added
    
    case STX_ZeroPage = 0x86        // Test Added
    case STX_ZeroPageY = 0x96       // Test Added
    case STX_Absolute = 0x8E        // Test Added
    
    case STY_ZeroPage = 0x84        // Test Added
    case STY_ZeroPageX = 0x94       // Test Added
    case STY_Absolute = 0x8C        // Test Added

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
    
    case JSR = 0x20                 // Test added
    case RTS = 0x60                 // Test added
    
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
    case AND_Immediate = 0x29       // Test added
    case AND_ZeroPage = 0x25        // Test added
    case AND_ZeroPageX = 0x35       // Test added
    case AND_Absolute = 0x2D        // Test added
    case AND_AbsoluteX = 0x3D       // Test added
    case AND_AbsoluteY = 0x39       // Test added
    case AND_IndirectX = 0x21       // Test added
    case AND_IndirectY = 0x31       // Test added
    
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
    case ASL_Accumulator = 0x0A     // Test added
    case ASL_ZeroPage = 0x06        // Test added
    case ASL_ZeroPageX = 0x16       // Test added
    case ASL_Absolute = 0x0E        // Test added
    case ASL_AbsoluteX = 0x1E       // Test added
    
    case LSR_Accumulator = 0x4A     // Test added
    case LSR_ZeroPage = 0x46        // Test added
    case LSR_ZeroPageX = 0x56       // Test added
    case LSR_Absolute = 0x4E        // Test added
    case LSR_AbsoluteX = 0x5E       // Test added
    
    case ROL_Accumulator = 0x2A     // Test added
    case ROL_ZeroPage = 0x26        // Test added
    case ROL_ZeroPageX = 0x36       // Test added
    case ROL_Absolute = 0x2E        // Test added
    case ROL_AbsoluteX = 0x3E       // Test added
    
    case ROR_Accumulator = 0x6A     // Test added
    case ROR_ZeroPage = 0x66        // Test added
    case ROR_ZeroPageX = 0x76       // Test added
    case ROR_Absolute = 0x6E        // Test added
    case ROR_AbsoluteX = 0x7E       // Test added
    
    // MARK: Branch
    case BCC = 0x90                 // Test added
    case BCS = 0xB0                 // Test added
    case BEQ = 0xF0                 // Test added
    case BMI = 0x30                 // Test added
    case BNE = 0xD0                 // Test added
    case BPL = 0x10                 // Test added
    case BVC = 0x50                 // Test added
    case BVS = 0x70                 // Test added
    
    // MARK: Compare
    case CMP_Immediate = 0xC9       // Test added
    case CMP_ZeroPage = 0xC5        // Test added
    case CMP_ZeroPageX = 0xD5       // Test added
    case CMP_Absolute = 0xCD        // Test added
    case CMP_AbsoluteX = 0xDD       // Test added
    case CMP_AbsoluteY = 0xD9       // Test added
    case CMP_IndirectX = 0xC1       // Test added
    case CMP_IndirectY = 0xD1       // Test added
    
    case CPX_Immediate = 0xE0       // Test added
    case CPX_ZeroPage = 0xE4        // Test added
    case CPX_Absolute = 0xEC        // Test added
  
    case CPY_Immediate = 0xC0       // Test added
    case CPY_ZeroPage = 0xC4        // Test added
    case CPY_Absolute = 0xCC        // Test added
    
    // MARK: Clear flags
    case CLC = 0x18                 // Test added
    case CLD = 0xD8                 // Test added
    case CLI = 0x58                 // Test added
    case CLV = 0xB8                 // Test added
    
    // MARK: Set flags
    case SEC = 0x38                 // Test added
    case SED = 0xF8                 // Test added
    case SEI = 0x78                 // Test added
    
    // MARK: Misc.
    case BRK = 0x00
    case NOP = 0xEA                 // Test added
    case BIT_ZeroPage = 0x24        // Test added
    case BIT_Absolute = 0x2C        // Test added
    case RTI = 0x40
}
