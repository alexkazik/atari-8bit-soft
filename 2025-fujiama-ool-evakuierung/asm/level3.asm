    .pc = * "level 3"

level3_init:
    jsr player_init

    lda # $6a
    sta planet_color

    lda # 2*40
    jsr set_line_bottom

    inc line_top1+24

    ldy # 20*3 - 1
    ldx # 9
!lp:
    // bottom line
    lda level3_shift_hi, x
    sta dlist+9, y
    dey
    lda level3_shift_lo, x
    sta dlist+9, y
    dey
    dey
    // top line
    lda level3_shift_hi, x
    sta dlist+9, y
    dey
    lda level3_shift_lo, x
    sta dlist+9, y
    dey
    dey
    dex
    bpl !lp-

    lda # 96
    sta start

    lda # 104-player_y_shift
    ldy # 0
    jsr player_copy_start
    lda # 104-player_y_shift
    ldy # 1
    jsr player_copy_start

    // already done
    lda # 24-player_y_shift
    sta player_y+2
    sta player_y+3

    lda # 21*3+1
    sta player_dlist+0
    sta player_dlist+1
    lda # 23*3+1 // disable
    sta player_dlist+2
    sta player_dlist+3

    // horiz pos player
    lda # 8
    sta player_x+0
    lda # $30 + 8*4
    sta gtia.hposp0
    lda # 26
    sta player_x+1
    lda # $30 + 26*4
    sta gtia.hposp1
    lda # 0 // don't show
    sta gtia.hposp2
    sta gtia.hposp3

    lda # dlist + 3 + 20*3 + 1
    sta dlist_ptr+0
    lda # (dlist + 3 + 20*3 + 1) >> 8
    sta dlist_ptr+1

    rts
