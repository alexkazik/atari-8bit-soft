    .pc = * "screen2.asm"

    .pc = * "screen2 dlist (page 1024)"
    // Das "(page 1024)" sorgt dafür dass in der nachbearbeitung (kick_assembler.rs)
    // geprüft wird ob diese Sektion komplett in einer 1024 byte Seite liegt.
screen2_dlist:
    .byte $70, $70, $30
    .byte $44, screen2, screen2 >> 8
    .fill 24, $04
    .byte $41, screen2_dlist, screen2_dlist >> 8

    .pc = * "screen2 run"
run_intro2:
    lda # screen2_dlist
    sta antic.dlist.lo
    lda # screen2_dlist >> 8
    sta antic.dlist.hi

    ldx # 10
    lda antic.vcount
!loop1:
    cmp antic.vcount
    beq !loop1-
!loop:
    cmp antic.vcount
    bne !loop-

    dex
    bne !loop1-

!loop:
    lda gtia.trig0
    beq !loop-

!loop:
    lda gtia.trig0
    bne !loop-

    jmp run_intro
