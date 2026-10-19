.ORIG x3000

    lea r0, Addr
    ld r1, Value

    halt

Addr    .BLKW #1
Value   .FILL x300C

.END
