; R6 is used to track failures

.ORIG x3000

    jsr Sub

    lea r7, Jump
    ret

    br Fail

Jump
    jsr Pass

Sub
    ret

Fail
    add r6, r6, #1
    halt

Pass
    halt

.END
