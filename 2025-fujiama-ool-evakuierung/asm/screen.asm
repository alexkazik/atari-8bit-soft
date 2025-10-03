    .pc = * "screen.asm"

    .pc = * "screen dlist (page 1024)"
    // Das "(page 1024)" sorgt dafür dass in der nachbearbeitung (kick_assembler.rs)
    // geprüft wird ob diese Sektion komplett in einer 1024 byte Seite liegt.
screen_dlist:
    .byte $70, $70, $30
    .byte $44, screen, screen >> 8
    .fill 24, $04
    .byte $41, screen_dlist, screen_dlist >> 8

    .pc = * "screen run"
run_intro:
    lda # screen_dlist
    sta antic.dlist.lo
    lda # screen_dlist >> 8
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

    jsr level1_init

    lda # dlist
    sta antic.dlist.lo
    lda # dlist >> 8
    sta antic.dlist.hi


    jsr game_loop

    jsr level2_init
    jsr game_loop

    jsr level3_init
    jsr game_loop

    jsr level4_init
    jsr game_loop

    jsr level5_init
    jsr game_loop

    jsr level6_init
    jsr game_loop

    jmp run_intro2
