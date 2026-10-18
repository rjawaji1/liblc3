package lc3

memset :: proc(lc3: ^LC3, address, value: u16) {
	lc3.memory[address] = value
}

memread :: proc(lc3: ^LC3, address: u16) -> u16 {
	return lc3.memory[address]
}
