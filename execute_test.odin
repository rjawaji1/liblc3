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
