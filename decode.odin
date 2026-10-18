package lc3

Opcode :: enum u8 {
	Br       = 0x0,
	Add      = 0x1,
	Ld       = 0x2,
	St       = 0x3,
	Jsr_Jsrr = 0x4,
	And      = 0x5,
	Ldr      = 0x6,
	Str      = 0x7,
	Rti      = 0x8,
	Not      = 0x9,
	Ldi      = 0xA,
	Sti      = 0xB,
	Jmp_Ret  = 0xC,
	Reserved = 0xD,
	Lea      = 0xE,
	Trap     = 0xF,
}

Condition_Code :: enum u8 {
	P = 1 << 0,
	Z = 1 << 1,
	N = 1 << 2,
}

extract_bits :: proc(instruction: u16, offset, width: u8) -> u16{
	mask: u16 = (1 << width) - 1
	return (instruction >> offset) & mask
}

extract_reg_dst :: proc(instruction: u16) -> u16 {
	return extract_bits(instruction, 9, 3)
}

extract_reg_src1 :: proc(instruction: u16) -> u16 {
	return extract_bits(instruction, 6, 3)
}

extract_reg_src2 :: proc(instruction: u16) -> u16 {
	return extract_bits(instruction, 0, 3)
}

extract_reg_base :: proc(instruction: u16) -> u16 {
	return extract_bits(instruction, 6, 3)
}

extract_imm5 :: proc(instruction: u16) -> u16 {
	return u16(sign_extend(extract_bits(instruction, 0, 5), 5))
}

extract_pcoffset11 :: proc(instruction: u16) -> u16 {
	return u16(sign_extend(extract_bits(instruction, 0, 11), 11))
}

extract_pcoffset9 :: proc(instruction: u16) -> u16{
	return u16(sign_extend(extract_bits(instruction, 0, 9), 9))
}

extract_offset6 :: proc(instruction: u16) -> u16 {
	return u16(sign_extend(extract_bits(instruction, 0, 6), 6))
}

is_bit_set :: proc(instruction: u16, position: u8) -> bool {
	return extract_bits(instruction, position, 1) == 1
}

sign_extend :: proc(value: u16, width: u8) -> i16 {
	shift := 16 - width
	return i16(value << shift) >> shift
}
