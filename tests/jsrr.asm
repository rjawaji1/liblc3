; R6 is used to track failures

.ORIG x3000

    lea r0, Pass
    jsrr r0
    br Fail

Fail
    add r6, r6, #1
    halt

Pass
    halt

.END
