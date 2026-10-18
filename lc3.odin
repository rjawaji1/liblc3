package lc3

MEMORY_SIZE :: 0x10000

Error :: enum {
	None,
	Halted,
	Unsupported_Trap,
	Unsupported_Instruction,
	Reserved_Instruction,
}

LC3 :: struct {
	memory:     [MEMORY_SIZE]u16,
	registers:  [8]u16,
	pc:	        u16,
	cc:         Condition_Code,

	traps:      map[u8]Trap_Handler,
	halted:     bool,

	initial_pc: u16,
}

init :: proc(lc3: ^LC3){
	lc3^ = LC3 {
		pc = 0x3000,
		cc = .N,
		halted = false,
	}

	// Register Traps
	register_trap_halt(lc3)
}

reset :: proc(lc3: ^LC3){
	lc3.registers = {}
	lc3.pc = lc3.initial_pc
	lc3.cc = .N
	lc3.halted = false
}

destroy :: proc(lc3: ^LC3){
	delete(lc3.traps)
}

load_buffer :: proc(lc3: ^LC3, buffer: []u16){
	lc3.initial_pc = buffer[0]
	lc3.pc = lc3.initial_pc

	copy(lc3.memory[lc3.pc:], buffer[1:])
}
