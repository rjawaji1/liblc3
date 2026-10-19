package main

import "core:fmt"
import "core:os"

import lc3 ".."

main :: proc() {
	runtime := new(lc3.LC3)
	defer free(runtime)

	lc3.init(runtime)
	defer lc3.destroy(runtime)

	lc3.register_trap(runtime, 0x27, reg_callback, nil)

	reg_callback :: proc(lc3: ^lc3.LC3, user_data: rawptr){
		for i in 0..<8 {
			fmt.printfln("Reg 0x%X : 0x%X", i, lc3.registers[i])
		}
	}

	if !lc3.load_file_from_file(runtime, os.stdin) {
		fmt.eprintln("Failed to load program")
		return
	}
	for !runtime.halted {
		err := lc3.step(runtime)
		if err != .None {
			fmt.eprintfln("Execution failed: %v", err)
			return
		}
	}
}
