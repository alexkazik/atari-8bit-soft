    .import source "atari.asm"

    .const screen = $a000

    .pc = $80 "ZP" virtual
temp1:
    .fill 2,0
temp2:
    .fill 2,0
buffer_start:
    .fill 2,0
buffer_end:
    .fill 2,0
rend_x:
    .fill 1,0
rend_y:
    .fill 1,0
rend_s:
    .fill 1,0
rend_pos:
    .fill 1,0
draw_lines:
    .fill 1,0
draw_chars:
    .fill 1,0
draw_ptr:
    .fill 2,0
draw_color:
    .fill 1,0
draw_mask:
    .fill 1,0
colbk:
    .fill 1,0
col0:
    .fill 1,0
col1:
    .fill 1,0
col2:
    .fill 1,0
colx:
    .fill 1,0


    .pc = $2000 "start"
start:
    sei

    lda # 0
    sta antic.nmien

    lda # $23
    sta antic.dmactl

    lda # 0
    sta antic.chactl

    lda # $1e
    sta gtia.colbk
    sta colbk

    lda # $3c
    sta gtia.colpf0
    sta col0

    lda # $5c
    sta gtia.colpf1
    sta col1

    lda # $7c
    sta gtia.colpf2
    sta col2

    lda # $ac
    sta colx

    // ack nmi
    lda # $ff
    sta antic.nmires
    // no os/basic
    lda # $fe
    sta pia.orb

    lda # dlist
    sta temp1+0
    lda # dlist >> 8
    sta temp1+1

    lda # (screen+4*256/4+32/4)
    sta temp2+0
    lda # (screen+4*256/4+32/4) >> 8
    sta temp2+1

    ldx # 120
!loop:
    ldy # 0
    lda # $4d
    sta (temp1), y
    iny
    lda temp2+0
    sta (temp1), y
    iny
    lda temp2+1
    sta (temp1), y

    lda temp1+0
    clc
    adc # 3
    sta temp1+0
    bcc !skip+
    inc temp1+1
!skip:

    lda temp2+0
    clc
    adc # 64
    sta temp2+0
    bcc !skip+
    inc temp2+1
!skip:

    dex
    bne !loop-

    ldy # 0
    lda # $41
    sta (temp1), y
    iny
    lda # dlist
    sta (temp1), y
    iny
    lda # dlist >> 8
    sta (temp1), y

    lda # dlist
    sta antic.dlist.lo
    lda # dlist >> 8
    sta antic.dlist.hi

    // nmi vector
    lda # nmi
    sta $fffa
    lda # nmi >> 8
    sta $fffb

    lda # $40
    sta antic.nmien


    ldy # 0
    tya
!loop:
    .for(var i=screen; i<screen+$2000; i += $100){
        sta i, y
    }
    iny
    bne !loop-

    // jmp *
    jmp render

    .import source "render.asm"
    .import source "draw.asm"

    .pc = * "nmi"
nmi:
    pha

    // update dlist
    lda # dlist
    sta antic.dlist.lo
    lda # dlist >> 8
    sta antic.dlist.hi

    // ack nmi
    sta antic.nmires

    // return
    pla
    rti

    .pc = * "FREE" virtual
    .align $400

    .pc = * "dlist" virtual
dlist:
    .fill $200, 0

    .pc = screen "screen" virtual
    .fill 256/4 * 128, 0

    .pc = $3000 "buffer" virtual
buffer:
    .const buffer_elements = $6000/3
    .fill buffer_elements*3, 0
buffer_behind_last:
