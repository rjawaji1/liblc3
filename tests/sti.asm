.ORIG x3000

    add r0, r0, #3
    sti r0, Value

    halt

Value .FILL x3004
      .BLKW #1

.END
