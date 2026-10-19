package lc3

import "core:testing"

@(test)
execute_add_test :: proc(t: ^testing.T) {
	vm: LC3

	init(&vm)
	defer destroy(&vm)

	ok := load(&vm, "tests/add.obj")
	testing.expect(t, ok)

	for step(&vm) == .None {}

	testing.expect(t, vm.registers[2] == 0)
	testing.expect(t, vm.cc == .Z)
}

@(test)
execute_and_test :: proc(t: ^testing.T) {
	vm: LC3

	init(&vm)
	defer destroy(&vm)

	ok := load(&vm, "tests/and.obj")
	testing.expect(t, ok)

	for step(&vm) == .None {}

	testing.expect(t, vm.registers[3] == 0b1001)
	testing.expect(t, vm.registers[4] == 0b1010)
	testing.expect(t, vm.registers[5] == 0b1000)
}
