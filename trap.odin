package lc3

TRAP_VECTOR_HALT :: 0x25

Trap_Callback :: proc(lc3: ^LC3, user_data: rawptr)

Trap_Handler :: struct {
	callback:  Trap_Callback,
	user_data: rawptr,
}

register_trap :: proc(lc3: ^LC3, trap: u8, callback: Trap_Callback, user_data: rawptr) {
	lc3.traps[trap] = {
		callback  = callback,
		user_data = user_data,
	}
}

register_trap_halt :: proc(lc3: ^LC3) {
	register_trap(lc3, TRAP_VECTOR_HALT, trap_halt_callback, nil)

	trap_halt_callback :: proc(lc3: ^LC3, user_data: rawptr) {
		lc3.halted = true
	}
}
