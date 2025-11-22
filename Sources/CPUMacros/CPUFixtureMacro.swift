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

        var assertInitialState = true

        for arg in node.arguments {
            if let label = arg.label, label.text == "assertInitialState" {
                if let boolExpr = arg.expression.as(BooleanLiteralExprSyntax.self) {
                    assertInitialState = (boolExpr.literal.tokenKind == .keyword(.true))
                }
            }
        }

        var bodyLines: [String] = []
        bodyLines.append("let memory = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x10000)")
        bodyLines.append("defer { memory.deallocate() }")
        bodyLines.append("let cpu = CPU6502(memory: memory)")

        if assertInitialState {
            bodyLines.append("#expect(cpu.A == 0)")
            bodyLines.append("#expect(cpu.X == 0)")
            bodyLines.append("#expect(cpu.Y == 0)")
            bodyLines.append("#expect(cpu.SP == 0xFF)")
            bodyLines.append("#expect(cpu.PC == cpu.readWord(addr: cpu.resetVector))")
            bodyLines.append("#expect(cpu.F == Flags.One.rawValue)")
        }

        bodyLines.append("return (cpu, memory)")

        let bodySource = bodyLines.joined(separator: "\n")

        let expansion: ExprSyntax = """
        { () -> (CPU6502, UnsafeMutablePointer<UInt8>) in
        \(raw: bodySource)
        }()
        """

        return expansion
    }
}

