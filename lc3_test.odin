package lc3

import "core:testing"

@(test)
add_test :: proc(t: ^testing.T){
	lc3: LC3

	init(&lc3)

	lc3.registers[0x1] = 10
	lc3.registers[0x2] = 20

	lc3.memory[lc3.pc] = 0b0001000001000010

	step(&lc3)

	testing.expect(
		t,
		lc3.registers[0x0] == 30,
		"Add Instruction failed to equal to 30",
	)
}
