#+private file
package lc3

import "core:testing"

load_and_run_vm :: proc(vm: ^LC3, path: string) -> bool {
	init(vm)

	load(vm, path) or_return

	for step(vm) == .None {}
	return true
}

@(test)
execute_add_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/add.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[2] == 0)
	testing.expect(t, vm.cc == .Z)
}

@(test)
execute_and_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/and.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[3] == 0b1001)
	testing.expect(t, vm.registers[4] == 0b1010)
	testing.expect(t, vm.registers[5] == 0b1000)
}

@(test)
execute_br_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/br.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[6] == 0)
}

@(test)
execute_jmp_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/jmp.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[6] == 0)
}

@(test)
execute_jsr_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/jsr.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[6] == 0)
}

@(test)
execute_jsrr_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/jsrr.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[6] == 0)
}

@(test)
execute_ld_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/ld.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[0] == 3)
}

@(test)
execute_ldi_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/ldi.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[0] == 3)
}

@(test)
execute_ldr_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/ldr.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[0] == 3)
}

@(test)
execute_lea_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/lea.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[0] == 0x3003)
	testing.expect(t, vm.registers[1] == 0x300C)
}

@(test)
execute_not_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/not.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[0] == 0b1111111111110000)
	testing.expect(t, vm.registers[1] == 0b1111111111111111)
}

@(test)
execute_ret_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/ret.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.registers[6] == 0)
}


@(test)
execute_st_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/st.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.memory[0x3003] == 3)
}

@(test)
execute_sti_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/sti.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.memory[0x3004] == 3)
}

@(test)
execute_str_test :: proc(t: ^testing.T) {
	vm: LC3
	defer destroy(&vm)

	ok := load_and_run_vm(&vm, "tests/str.obj")
	testing.expect(t, ok)

	testing.expect(t, vm.memory[0x3005] == 3)
}
