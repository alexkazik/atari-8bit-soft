    .pc = * "game_loop.asm"

game_loop:
    lda start
l0:
    cmp antic.vcount
    bne l0

    ldx # $76
    stx gtia.colpf3

    ldx # $04
    stx gtia.colpf0
    ldx planet_color
    stx gtia.colpf1
    ldx # $0e
    stx gtia.colpf2

    clc
    adc # 8

l1:
    cmp antic.vcount
    bne l1

    ldx # $72
    stx gtia.colpf3

    // search for end of screen

    lda # 112
l2:
    cmp antic.vcount
    bne l2

    // check for player finished
    lda # 4
    sta temp+1
    ldy # 3
!ploop:
    lda player_y, y
    cmp # 24-player_y_shift
    bne !skip+

    sty temp+0
    jsr player_ok
    dec temp+1
    ldy temp+0

!skip:
    dey
    bpl !ploop-

    lda temp+1
    bne !skip+
    jmp go_next
!skip:

    // check for move player Y
    ldy # 3
!ploop:
    ldx player_dlist, y
    lda dlist+0, x
    clc
    adc player_x, y
    sta temp+0
    lda dlist+1, x
    sta temp+1
    ldx # 0
    lda (temp, x)
    cmp # $9e
    bne !skip+
    jsr move_pl
!skip:
    dey
    bpl !ploop-

    // joy repeat
    dec joy_repeat
    bne !skip+
    lda # $ff
    sta last_joy
!skip:

    // joy movement
    lda pia.piba
    tax
    eor last_joy
    eor # $ff
    ora pia.piba
    stx last_joy
    tax

    and # $01
    bne !skip+

    lda start
    cmp # 24
    beq !skip+
    sec
    sbc # 8
    sta start

    lda dlist_ptr+0
    sec
    sbc # 6
    sta dlist_ptr+0

    lda # joy_repeat_y
    sta joy_repeat

    jsr score
!skip:

    txa
    and # $02
    bne !skip+

    lda start
    cmp # 96
    beq !skip+
    clc
    adc # 8
    sta start


    lda dlist_ptr+0
    clc
    adc # 6
    sta dlist_ptr+0

    lda # joy_repeat_y
    sta joy_repeat

    jsr score
!skip:

    lda start
    cmp # 24
    beq !skip+
    sec
    sbc # player_y_shift
    cmp player_y+0
    beq !no_horiz+
    cmp player_y+1
    beq !no_horiz+
    cmp player_y+2
    beq !no_horiz+
    cmp player_y+3
    beq !no_horiz+
!skip:

    txa
    and # $04
    bne !skip+

    ldy # 3
!lp:
    lda (dlist_ptr), y
    clc
    adc # 2
    and # $80 | $3f
    sta (dlist_ptr), y
    dey
    dey
    dey
    bpl !lp-
    lda # joy_repeat_x
    sta joy_repeat
    jsr score
!skip:

    txa
    and # $08
    bne !skip+

    ldy # 3
!lp:
    lda (dlist_ptr), y
    and # $7f
    beq !wrap+

    lda (dlist_ptr), y
    sec
    sbc # 2
    jmp !st+
!wrap:
    lda (dlist_ptr), y
    ora # $3e
!st:
    sta (dlist_ptr), y
    dey
    dey
    dey
    bpl !lp-
    lda # joy_repeat_x
    sta joy_repeat
    jsr score
!skip:

!no_horiz:

    lda # font_col1
    sta gtia.colpf0

    lda # font_col2
    sta gtia.colpf1

    lda # font_col3
    sta gtia.colpf2

    jmp game_loop


move_pl:
    // y = pl
    lda player_dlist, y
    sec
    sbc # 6
    sta player_dlist, y

    lda player_y, y
    sec
    sbc # 8
    jsr player_copy

    rts

go_next:
    lda # 0
    sta temp+0
!loop:
    lda antic.vcount
    cmp # 60
    bne !skip+

    ldx # $04
    stx gtia.colpf0
    ldx planet_color
    stx gtia.colpf1
    ldx # $0e
    stx gtia.colpf2

    jmp !skip2+
!skip:
    cmp # 112
    bne !skip2+

    lda # font_col1
    sta gtia.colpf0
    lda # font_col2
    sta gtia.colpf1
    lda # font_col3
    sta gtia.colpf2

!skip2:
    lda gtia.trig0
    bne !no_press+

    // pressed
    lda # 1
    sta temp+0
    jmp !loop-

!no_press:
    lda temp+0
    beq !loop-

    lda # 0 // don't show
    sta gtia.hposp0
    sta gtia.hposp1
    sta gtia.hposp2
    sta gtia.hposp3

    rts


    .pc = * "set_line_bottom"
set_line_bottom:
    tay
    clc
    adc # line_bottom1
    sta dlist_bottom+1
    lda # 0
    adc # line_bottom1 >> 8
    sta dlist_bottom+2

    tya
    clc
    adc # line_bottom2
    sta dlist_bottom+4
    lda # 0
    adc # line_bottom2 >> 8
    sta dlist_bottom+5

    rts

score:
    ldy # screen_total_score_len-1
!repeat:
    lda screen_total_score, y
    clc
    adc # 1
    sta screen_total_score, y
    cmp # '9'+1
    bne !skip+
    lda # '0'
    sta screen_total_score, y
    dey
    bpl !repeat-
!skip:

    ldy # 2
!repeat:
    lda line_top1+28, y
    clc
    adc # 1
    sta line_top1+28, y
    cmp # '9'+1
    bne !skip+
    lda # '0'
    sta line_top1+28, y
    dey
    bpl !repeat-
!skip:

    rts
