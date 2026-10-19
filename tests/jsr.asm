; R6 is used to track failures

.ORIG x3000

    jsr Pass
    br Fail

Fail
    add r6, r6, #1
    halt

Pass
    halt

.END
