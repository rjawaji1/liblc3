package lc3

import "core:os"
import "core:encoding/endian"

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


load_file :: proc {
	load_file_from_path,
	load_file_from_file,
}

load_file_from_path :: proc(lc3: ^LC3, filepath: string) -> bool {
	file, file_err := os.open(filepath)
	if file_err != nil {
		return false
	}
	defer os.close(file)
	return load_file_from_file(lc3, file)
}

load_file_from_file :: proc(lc3: ^LC3, file: ^os.File) -> bool {
	buffer, read_err := os.read_entire_file(file, context.allocator)
	defer delete(buffer)
	if read_err != nil {
		return false
	}

	origin, ok := endian.get_u16(buffer, .Big)
	if !ok {
		return false
	}

	payload := buffer[2:]
	if len(payload) % 2 != 0 {
		return false
	}

	word_count := len(payload) / 2
	if word_count > MEMORY_SIZE - int(origin) {
		return false
	}

	for i := 0; i < word_count; i += 1 {
		word := endian.unchecked_get_u16be(payload[i*2:])
		lc3.memory[int(origin) + i] = word
	}

	lc3.initial_pc = origin
	lc3.pc = origin
	return true
}
