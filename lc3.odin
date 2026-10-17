package lc3

import "core:fmt"

MEMORY_SIZE :: 0xFFFF

LC3 :: struct {
	memory:    [MEMORY_SIZE]u16,
	registers: [8]u16,
	pc:	       u16,
	cc:        Condition_Code,
}

init :: proc(lc3: ^LC3){
	lc3^ = LC3 {
		pc = 0x3000,
		cc = .N,
	}
}

step :: proc(lc3: ^LC3){
	instruction := lc3.memory[lc3.pc]
	opcode := Opcode(extract_bits(instruction, 12, 4))

	lc3.pc += 1

	switch opcode {
	case .Br:       process_br(lc3, instruction)
	case .Add:      process_add(lc3, instruction)
	case .Ld:       fmt.printfln("Unimplemented Instruction: Ld")
	case .St:       fmt.printfln("Unimplemented Instruction: St")
	case .Jsr_Jsrr: fmt.printfln("Unimplemented Instruction: Jsr_Jsrr")
	case .And:      process_and(lc3, instruction)
	case .Ldr:      fmt.printfln("Unimplemented Instruction: Ldr")
	case .Str:      fmt.printfln("Unimplemented Instruction: Str")
	case .Rti:      fmt.printfln("Unimplemented Instruction: Rti")
	case .Not:      fmt.printfln("Unimplemented Instruction: Not")
	case .Ldi:      fmt.printfln("Unimplemented Instruction: Ldi")
	case .Sti:      fmt.printfln("Unimplemented Instruction: Sti")
	case .Jmp_Ret:  fmt.printfln("Unimplemented Instruction: Jmp_Ret")
	case .Reserved: fmt.printfln("Unimplemented Instruction: Reserved")
	case .Lea:      fmt.printfln("Unimplemented Instruction: Lea")
	case .Trap:     fmt.printfln("Unimplemented Instruction: Trap")
	}
}

process_add :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_bits(instruction, 9, 3)
	reg_src1 := extract_bits(instruction, 6, 3)

	operand: u16
	if is_bit_set(instruction, 5) {
		imm5 := extract_bits(instruction, 0, 5)
		operand = u16(sign_extend(imm5, 5))
	} else {
		reg_src2 := extract_bits(instruction, 0, 3)
		operand = lc3.registers[reg_src2]
	}

	lc3.registers[reg_dst] = lc3.registers[reg_src1] + operand
	update_condition_codes(lc3, reg_dst)
}

process_and :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_bits(instruction, 9, 3)
	reg_src1 := extract_bits(instruction, 6, 3)
	operand: u16

	if is_bit_set(instruction, 5) {
		imm5 := extract_bits(instruction, 0, 5)
		operand = u16(sign_extend(imm5, 5))
	} else {
		reg_src2 := extract_bits(instruction, 0, 3)
		operand = lc3.registers[reg_src2]
	}

	lc3.registers[reg_dst] = lc3.registers[reg_src1] & operand
	update_condition_codes(lc3, reg_dst)
}

process_br :: proc(lc3: ^LC3, instruction: u16) {
	pcoffset9 := u16(sign_extend(extract_bits(instruction, 0, 9), 9))
	nzp := extract_bits(instruction, 9, 3)

	if (nzp != 0) && ((u16(lc3.cc) & nzp) == 0) do return

	lc3.pc += pcoffset9
}

update_condition_codes :: proc(lc3: ^LC3, register: u16){
	value := lc3.registers[register]

	if value == 0 {
	 	lc3.cc = .Z
	} else if is_bit_set(value, 15) {
	 	lc3.cc = .N
	} else {
	 	lc3.cc = .P
	}
}
