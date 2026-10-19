.ORIG x3000

    lea r3, Value

    add r0, r0, #3
    str r0, r3, #1

    halt

Value .BLKW #2

.END
