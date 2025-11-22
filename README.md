# Swift6502

A Swift package that implements all opcodes for a MOS 6502 processor along with tests.

Swift6502 is **not** ready for the prime time. It has only been tested against the tests provided, so will almost certainly fail when presented with real world code.

Swift6502 is only the CPU core. There are hooks for I/O, but no devices are provided. It's up to client code to provide and hook up devices such as a keyboard and display.

WozMon appears to work to some degree in the debugger. Need to figure out what values it expects from I/O reads.
