    .pc = * "player.asm"

    .pc = * "player_init"
player_init:
    lda # pmbase >> 8
    sta antic.pmbase

    // double player width
    lda # 0
    sta gtia.sizep0

    lda # color_player_start
    sta gtia.colpm0
    sta gtia.colpm1
    sta gtia.colpm2
    sta gtia.colpm3

    // enable players
    lda # 2
    sta gtia.gractl

    // clear player
    lda # 0
    ldy # 0
!loop:
    sta pmbase+$400, y // player 0
    sta pmbase+$500, y // player 1
    sta pmbase+$600, y // player 2
    sta pmbase+$700, y // player 3
    iny
    bne !loop-

    // clear level score
    lda # '0'
    sta line_top1+28
    sta line_top1+29
    sta line_top1+30

    rts


    .pc = * "player_copy"
player_copy:
    // A = new y-pos
    // Y = player!
    // retains Y
    sty !smc_pl_1+ +1
    sty !smc_pl_2+ +1
    pha

    tya

    ora # (pmbase+$400) >> 8
    sta !smc1+ +2
    sta !smc2+ +2

    lda player_y, y
    asl
    tay
    lda # 0
    ldx # 16
!loop:
!smc1:
    sta pmbase+$400, y
    iny
    dex
    bpl !loop-

!smc_pl_1:
    ldy # 0

    pla
    sta player_y, y
    asl
    tay
    ldx # 0
!loop:
    lda player_data, x
!smc2:
    sta pmbase+$400, y
    iny
    inx
    cpx # 16
    bne !loop-

!smc_pl_2:
    ldy # 0
    rts

    .pc = * "player_copy_start"
player_copy_start:
    // A = new y-pos
    // Y = player!
    // retains Y
    sty !smc_pl_1+ +1
    sty !smc_pl_2+ +1
    pha

    tya

    ora # (pmbase+$400) >> 8
    sta !smc2+ +2

    lda player_y, y
    asl
    tay
    lda # 0
    ldx # 16

!smc_pl_1:
    ldy # 0

    pla
    sta player_y, y
    asl
    tay
    ldx # 0
!loop:
    lda player_start_data, x
!smc2:
    sta pmbase+$400, y
    iny
    inx
    cpx # 16
    bne !loop-

!smc_pl_2:
    ldy # 0
    rts

    .pc = * "player_ok"
player_ok:
    // Y = player!
    lda # color_player_ok
    sta gtia.colpm0, y

    tya
    ora # (pmbase+$400) >> 8
    sta !smc+ +2

    lda player_y, y
    asl
    tay
    ldx # 0
!loop:
    lda player_ok_data, x
!smc:
    sta pmbase+$400, y
    iny
    inx
    cpx # 16
    bne !loop-

    rts

    .pc = * "player start data"
player_start_data:
    .var picture_player_start = LoadPicture("graphics/player_start.png")
    .fill 16, picture_player_start.getSinglecolorByte(0, i)


    .pc = * "player data"
player_data:
    .var picture_player = LoadPicture("graphics/player.png")
    .fill 16, picture_player.getSinglecolorByte(0, i)

    .pc = * "player ok data"
player_ok_data:
    .var picture_player_ok = LoadPicture("graphics/player_ok.png")
    .fill 16, picture_player_ok.getSinglecolorByte(0, i)
