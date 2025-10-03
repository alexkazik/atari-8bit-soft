    .import source "../generated/atari.asm"

    .pc = $80 "ZP" virtual
temp:
    .fill 2, 0
col:
    .fill 1, 0
start:
    .fill 1, 0
last_joy:
    .fill 1, 0
joy_repeat:
    .fill 1, 0
dlist_ptr:
    .fill 2, 0
player_dlist:
    .fill 4, 0
player_y:
    .fill 4, 0
player_x:
    .fill 4, 0
planet_color:
    .fill 1, 0

    .const joy_repeat_x = 7
    .const joy_repeat_y = 7

    .const pmbase = $7800
    .const color_player_start = $0e
    .const color_player_ok = $b8
    .const player_y_shift = 3
    .const screen_total_score = screen2 + 11*40 + 17
    .const screen_total_score_len = 6

    .const font_col3 = $ae
    .const font_col2 = $a8
    .const font_col1 = $a4

    .pc = $2000 "font"
font:
    .var picture = LoadPicture("graphics/font.png", List().add($000000,$989898,$bebebe,$dadada))
    .for (var y=0; y<4; y++)
    .for (var x=0;x<32; x++)
    .for(var charPosY=0; charPosY<8; charPosY++)
    .byte picture.getMulticolorByte(x,y*8+charPosY)

    .pc = * "screen data (page 4096)"
    // Das "(page 4096)" sorgt dafür dass in der nachbearbeitung (kick_assembler.rs)
    // geprüft wird ob diese Sektion komplett in einer 4096 byte Seite liegt.
screen:
    .import binary "../generated/screen1.bin"

    .pc = * "screen2 data (page 4096)"
    // Das "(page 4096)" sorgt dafür dass in der nachbearbeitung (kick_assembler.rs)
    // geprüft wird ob diese Sektion komplett in einer 4096 byte Seite liegt.
screen2:
    .import binary "../generated/screen2.bin"

    .pc = * "planets (page 4096)"
line_bottom1:
    .byte 0,1,0,1,0,1,14,15,16,17,18,19,2,3,4,5,0,1,2,3,4,5,0,1,0,1,0,1,2,3,4,5,6,7,8,9,0,1,0,1
    .byte 2,3,4,5,0,1,2,3,4,5,14,15,16,17,18,19,2,3,4,5,0,1,0,1,6,7,8,9,0,1,0,1,0,1,0,1,0,1,0,1
    .byte 0,1,0,1,2,3,4,5,0,1,2,3,4,5,0,1,6,7,8,9,6,7,8,9,0,1,2,3,4,5,0,1,14,15,16,17,18,19,0,1
    .byte 0,1,0,1,0,1,14,15,16,17,18,19,0,1,14,15,16,17,18,19,2,3,4,5,0,1,0,1,6,7,8,9,0,1,0,1,2,3,4,5
    .byte 0,1,6,7,8,9,0,1,6,7,8,9,2,3,4,5,6,7,8,9,0,1,0,1,0,1,0,1,14,15,16,17,18,19,0,1,2,3,4,5
    .byte 2,3,4,5,6,7,8,9,6,7,8,9,2,3,4,5,0,1,14,15,16,17,18,19,0,1,6,7,8,9,0,1,14,15,16,17,18,19,0,1

line_bottom2:
    .byte 26,26,26,26,26,26,20,21,22,23,24,25,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,10,11,12,13,26,26,26,26
    .byte 26,26,26,26,26,26,26,26,26,26,20,21,22,23,24,25,26,26,26,26,26,26,26,26,10,11,12,13,26,26,26,26,26,26,26,26,26,26,26,26
    .byte 26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,10,11,12,13,10,11,12,13,26,26,26,26,26,26,26,26,20,21,22,23,24,25,26,26
    .byte 26,26,26,26,26,26,20,21,22,23,24,25,26,26,20,21,22,23,24,25,26,26,26,26,26,26,26,26,10,11,12,13,26,26,26,26,26,26,26,26
    .byte 26,26,10,11,12,13,26,26,10,11,12,13,26,26,26,26,10,11,12,13,26,26,26,26,26,26,26,26,20,21,22,23,24,25,26,26,26,26,26,26
    .byte 26,26,26,26,10,11,12,13,10,11,12,13,26,26,26,26,26,26,20,21,22,23,24,25,26,26,10,11,12,13,26,26,20,21,22,23,24,25,26,26

    .pc = * "FREE"
    .align $80

    .import source "../generated/levels.asm"

    .pc = * "dlist (page 1024)"
    // Das "(page 1024)" sorgt dafür dass in der nachbearbeitung (kick_assembler.rs)
    // geprüft wird ob diese Sektion komplett in einer 1024 byte Seite liegt.
dlist:
    .fill 3, $70
    .byte $44, line_top1, line_top1 >> 8
    .byte $44, line_top2, line_top2 >> 8
    .for (var y=0; y<20; y++){
        .byte $44, 0, 0
    }
dlist_bottom:
    .byte $44, line_bottom1, line_bottom1 >> 8
    .byte $44, line_bottom2, line_bottom2 >> 8
    .byte $41, dlist, dlist >> 8

    .pc = * "start"
run:
    sei

    lda # font >> 8
    sta antic.chbase

    lda # 0
    sta antic.nmien

    lda # $3a
    sta antic.dmactl

    lda # 0
    sta antic.chactl

    lda # 0
    sta gtia.colbk

    lda # font_col1
    sta gtia.colpf0

    lda # font_col2
    sta gtia.colpf1

    lda # font_col3
    sta gtia.colpf2

    lda # $01
    sta gtia.prior

    // ack nmi
    lda # $ff
    sta antic.nmires
    // no os/basic
    lda # $fe
    sta pia.orb

    jmp run_intro

    .pc = * "line_top1 (page 4096)"
line_top1:
    .encoding "ascii"
    .text "OOL EVAKUIERUNG - LEVEL X - XXX SCHRITTE"

line_top2:
    .fill 40, ' '

    .import source "player.asm"
    .import source "game_loop.asm"
    .import source "level1.asm"
    .import source "level2.asm"
    .import source "level3.asm"
    .import source "level4.asm"
    .import source "level5.asm"
    .import source "level6.asm"
    .import source "screen.asm"
    .import source "screen2.asm"
