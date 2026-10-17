package lc3

MEMORY_SIZE :: 0x10000

LC3 :: struct {
	memory:    [MEMORY_SIZE]u16,
	registers: [8]u16,
	pc:	       u16,
	cc:        Condition_Code,

	traps:     map[u8]Trap_Handler,
	halted:    bool,
}

init :: proc(lc3: ^LC3){
	lc3^ = LC3 {
		pc = 0x3000,
		cc = .N,
		halted = false,
	}

	// Register Traps
	register_trap_halt(lc3)
}

step :: proc(lc3: ^LC3) -> (err: int = 0) {
	if lc3.halted do return

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
	case .Rti:      err = 1
	case .St:       process_st(lc3, instruction)
	case .Sti:      process_sti(lc3, instruction)
	case .Str:      process_str(lc3, instruction)
	case .Trap:     process_trap(lc3, instruction)
	case .Reserved: err = 1
	}

	return
}

process_add :: proc(lc3: ^LC3, instruction: u16){
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

process_and :: proc(lc3: ^LC3, instruction: u16){
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

process_br :: proc(lc3: ^LC3, instruction: u16) {
	pcoffset9 := extract_pcoffset9(instruction)
	nzp := extract_bits(instruction, 9, 3)

	if (u16(lc3.cc) & nzp) == 0 do return

	lc3.pc += pcoffset9
}

process_jmp_ret :: proc(lc3: ^LC3, instruction: u16) {
	reg_base := extract_reg_base(instruction)
	lc3.pc = lc3.registers[reg_base]
}

process_jsr_jsrr :: proc(lc3: ^LC3, instruction: u16) {
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

process_ld :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.pc + pcoffset9
	lc3.registers[reg_dst] = lc3.memory[address]
	update_condition_codes(lc3, reg_dst)
}

process_ldi :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.memory[lc3.pc + pcoffset9]
	lc3.registers[reg_dst] = lc3.memory[address]
	update_condition_codes(lc3, reg_dst)
}

process_ldr :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	reg_base := extract_reg_base(instruction)
	offset6 := extract_offset6(instruction)

	address := lc3.registers[reg_base] + offset6
	lc3.registers[reg_dst] = lc3.memory[address]
	update_condition_codes(lc3, reg_dst)
}

process_lea :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	lc3.registers[reg_dst] = lc3.pc + pcoffset9
	update_condition_codes(lc3, reg_dst)
}

process_not :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	reg_src := extract_reg_src1(instruction)

	lc3.registers[reg_dst] = ~lc3.registers[reg_src]
	update_condition_codes(lc3, reg_dst)
}

process_st :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.pc + pcoffset9
	lc3.memory[address] = lc3.registers[reg_dst]
}

process_sti :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	pcoffset9 := extract_pcoffset9(instruction)

	address := lc3.memory[lc3.pc + pcoffset9]
	lc3.memory[address] = lc3.registers[reg_dst]
}

process_str :: proc(lc3: ^LC3, instruction: u16){
	reg_dst := extract_reg_dst(instruction)
	reg_base := extract_reg_base(instruction)
	offset6 := extract_offset6(instruction)

	address := lc3.registers[reg_base] + offset6
	lc3.memory[address] = lc3.registers[reg_dst]
}

process_trap :: proc(lc3: ^LC3, instruction: u16){
	trap_vector := u8(extract_bits(instruction, 0, 8))

	handler := lc3.traps[trap_vector]
	handler.callback(lc3, handler.user_data)
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
