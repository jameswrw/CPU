import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// Public macro declaration visible to clients (e.g., tests).
//@freestanding(expression)
//public macro cpuFixture(assertInitialState: Bool = true) -> (CPU6502, UnsafeMutablePointer<UInt8>) = #externalMacro(
//    module: "CPUMacros",
//    type: "CPUFixtureMacro"
//)

public struct CPUFixtureMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {

        // Default value for the optional parameter.
        var assertInitialState = true

        // SwiftSyntax 602: argumentList is a LabeledExprListSyntax, not optional.
        for arg in node.arguments {
            if let label = arg.label, label.text == "assertInitialState" {
                if let boolExpr = arg.expression.as(BooleanLiteralExprSyntax.self) {
                    assertInitialState = (boolExpr.literal.tokenKind == .keyword(.true))
                }
            }
        }

        // Build the body statements as source text to avoid tight coupling with specific Syntax nodes.
        var bodyLines: [String] = []
        bodyLines.append("let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)")
        bodyLines.append("defer { memory.deallocate() }")
        bodyLines.append("let cpu = CPU6502(memory: memory)")

        if assertInitialState {
            bodyLines.append("#expect(cpu.A == 0)")
            bodyLines.append("#expect(cpu.X == 0)")
            bodyLines.append("#expect(cpu.Y == 0)")
            bodyLines.append("#expect(cpu.SP == 0xFF)")
            bodyLines.append("#expect(cpu.PC == 0xFFFC)")
            bodyLines.append("#expect(cpu.F == Flags.One.rawValue)")
        }

        bodyLines.append("return (cpu, memory)")

        let bodySource = bodyLines.joined(separator: "\n")

        // Wrap in a closure expression and immediately call it so the macro is an expression.
        let expansion: ExprSyntax = """
        { () -> (CPU6502, UnsafeMutablePointer<UInt8>) in
        \(raw: bodySource)
        }()
        """

        return expansion
    }
}

