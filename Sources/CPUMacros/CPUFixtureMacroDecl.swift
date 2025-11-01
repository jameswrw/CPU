import CPU

@freestanding(expression)
public macro cpuFixture(assertInitialState: Bool = true) -> (CPU6502, UnsafeMutablePointer<UInt8>) = #externalMacro(
    module: "CPUMacros",
    type: "CPUFixtureMacro"
)

