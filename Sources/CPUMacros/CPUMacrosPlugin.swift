//
//  Swift6502MacrosPlugin.swift
//  Swift6502
//
//  Created by James Weatherley on 01/11/2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

public struct CPUMacrosPlugin: CompilerPlugin {
    public init() {}
    public let providingMacros: [Macro.Type] = [
        CPUFixtureMacro.self
    ]
}
