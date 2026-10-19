.ORIG x3000
    ; Reset Registers
    and r0, r0, #0
    and r1, r1, #0
    and r1, r2, #0

    ; Initialize Registers
    add r0, r0, #1
    add r1, r1, #1

    ; Perform Add
    add r2, r0, r1
    add r2, r2, #-2

    halt

.END
