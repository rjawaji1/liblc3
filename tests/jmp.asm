; R6 is used to track failures

.ORIG x3000

    lea r0, Pass
    jmp r0

    ; fail
    add r6, r6, #1
    halt

Pass
    halt

.END
