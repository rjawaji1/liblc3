package main

import "core:fmt"
import "core:os"
import "core:encoding/endian"

import lc3 ".."

main :: proc() {
	runtime := new(lc3.LC3)
	defer free(runtime)

	lc3.init(runtime)

	lc3.register_trap(runtime, 0x27, reg_callback, nil)

	reg_callback :: proc(lc3: ^lc3.LC3, user_data: rawptr){
		for i in 0..<8 {
			fmt.printfln("Reg 0x%X : 0x%X", i, lc3.registers[i])
		}
	}

	data, err := os.read_entire_file(os.stdin, context.allocator)
	if err != nil {
		fmt.eprintln("Read error:", err)
		return
	}
	defer delete(data)

	if len(data) < 2 || len(data) % 2 != 0 {
		fmt.eprintln("Invalid LC-3 object file")
		return
	}

	buffer := make([]u16, len(data)/2)
	defer delete(buffer)


	for i in 0..<len(buffer) {
		buffer[i] = endian.unchecked_get_u16be(data[i*2:])
	}

	pc := buffer[0]
	if int(pc) + len(buffer) - 1 > len(runtime.memory) {
		fmt.eprintln("Program exceeds LC-3 memory")
		return
	}

	fmt.printf("PC: 0x%04X (%d)\n", pc, pc)

	fmt.println("Loading Buffer")
	lc3.load_buffer(runtime, buffer)

	fmt.println("Running")
	for !runtime.halted {
		lc3.step(runtime)
	}
}
