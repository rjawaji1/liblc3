package lc3

MEMORY_SIZE :: 0xFFFF

CPU :: struct {
	registers: [8]u16,
	pc:	       u16,
	cc:        u8,
}

Machine :: struct {
	cpu:    CPU,
	memory: [MEMORY_SIZE]u16,
}

init :: proc(m: ^Machine){  
	m^ = {}
	m.cpu.pc = 0x3000
	m.cpu.cc = 0x2
}
