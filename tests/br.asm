; R6 is used to track failures

.ORIG x3000

    add r0, r0, #0
    brnp Fail

    add r0, r0, #1
    brnz Fail

    add r0, r0, #-2
    brzp Fail

    br Pass

Fail
    add r6, r6, #1
    halt

Pass
    halt

.END
