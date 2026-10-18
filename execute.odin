package lc3

step :: proc(lc3: ^LC3) -> (err: Error = .None) {
	if lc3.halted do return .Halted

	instruction := lc3.memory[lc3.pc]
	opcode := Opcode(extract_bits(instruction, 12, 4))

	lc3.pc += 1

	switch opcode {
	case .Add:      process_add(lc3, instruction)
	case .And:      process_and(lc3, instruction)
	case .Br:       process_br(lc3, instruction)
	case .Jmp_Ret:  process_jmp_ret(lc3, instruction)
	case .Jsr_Jsrr: process_jsr_jsrr(lc3, instruction)
	case .Ld:       process_ld(lc3, instruction)
	case .Ldi:      process_ldi(lc3, instruction)
	case .Ldr:      process_ldr(lc3, instruction)
	case .Lea:      process_lea(lc3, instruction)
	case .Not:      process_not(lc3, instruction)
	case .Rti:      err = .Unsupported_Instruction
	case .St:       process_st(lc3, instruction)
	case .Sti:      process_sti(lc3, instruction)
	case .Str:      process_str(lc3, instruction)
	case .Trap:     err = process_trap(lc3, instruction)
	case .Reserved: err = .Reserved_Instruction
	}

	return
}


@(private)
process_add :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	reg_src1 := extract_reg_src1(instruction)

	operand: u16
	if is_bit_set(instruction, 5) {
		operand = extract_imm5(instruction)
	} else {
		reg_src2 := extract_reg_src2(instruction)
		operand = lc3.registers[reg_src2]
	}

	lc3.registers[reg_dst] = lc3.registers[reg_src1] + operand
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_and :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	reg_src1 := extract_reg_src1(instruction)
	operand: u16

	if is_bit_set(instruction, 5) {
		operand = extract_imm5(instruction)
	} else {
		reg_src2 := extract_reg_src2(instruction)
		operand = lc3.registers[reg_src2]
	}

	lc3.registers[reg_dst] = lc3.registers[reg_src1] & operand
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_br :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	pcoffset9 := extract_pcoffset9(instruction)
	nzp := extract_bits(instruction, 9, 3)

	if (u16(lc3.cc) & nzp) == 0 do return

	lc3.pc += pcoffset9
}

@(private)
process_jmp_ret :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_base := extract_reg_base(instruction)
	lc3.pc = lc3.registers[reg_base]
}

@(private)
process_jsr_jsrr :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	target: u16
	if is_bit_set(instruction, 11) {
		target = lc3.pc + extract_pcoffset11(instruction)
	} else {
		reg_base := extract_reg_base(instruction)
		target = lc3.registers[reg_base]
	}

	lc3.registers[0x7] = lc3.pc
	lc3.pc = target
}

@(private)
process_ld :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.pc + pcoffset9
	lc3.registers[reg_dst] = lc3.memory[address]
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_ldi :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.memory[lc3.pc + pcoffset9]
	lc3.registers[reg_dst] = lc3.memory[address]
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_ldr :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	reg_base := extract_reg_base(instruction)
	offset6 := extract_offset6(instruction)

	address := lc3.registers[reg_base] + offset6
	lc3.registers[reg_dst] = lc3.memory[address]
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_lea :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	lc3.registers[reg_dst] = lc3.pc + pcoffset9
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_not :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	reg_src := extract_reg_src1(instruction)

	lc3.registers[reg_dst] = ~lc3.registers[reg_src]
	update_condition_codes(lc3, reg_dst)
}

@(private)
process_st :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.pc + pcoffset9
	lc3.memory[address] = lc3.registers[reg_dst]
}

@(private)
process_sti :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.memory[lc3.pc + pcoffset9]
	lc3.memory[address] = lc3.registers[reg_dst]
}

@(private)
process_str :: #force_inline proc(lc3: ^LC3, instruction: u16) {
	reg_dst := extract_reg_dst(instruction)
	reg_base := extract_reg_base(instruction)
	offset6 := extract_offset6(instruction)

	address := lc3.registers[reg_base] + offset6
	lc3.memory[address] = lc3.registers[reg_dst]
}

@(private)
process_trap :: #force_inline proc(lc3: ^LC3, instruction: u16) -> (err: Error = .None) {
	trap_vector := u8(extract_bits(instruction, 0, 8))

	handler, ok := lc3.traps[trap_vector]
	if !ok do return .Unsupported_Trap

	handler.callback(lc3, handler.user_data)

	return
}

@(private)
update_condition_codes :: proc(lc3: ^LC3, register: u16) {
	value := lc3.registers[register]

	if value == 0 {
	 	lc3.cc = .Z
	} else if is_bit_set(value, 15) {
	 	lc3.cc = .N
	} else {
	 	lc3.cc = .P
	}
}
