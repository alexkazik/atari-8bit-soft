    .pc = * "render"
render:
    // delay 50 frame

    ldx # 50
    lda antic.vcount
!loop1:
    cmp antic.vcount
    beq !loop1-
!loop:
    cmp antic.vcount
    bne !loop-

    dex
    bne !loop1-

    // random colors (swap)
    jsr get_rand2
    tax
    lda colbk, x
    ldy colx
    sta colx
    sty colbk, x

    lda colbk
    sta gtia.colbk
    lda col0
    sta gtia.colpf0
    lda col1
    sta gtia.colpf1
    lda col2
    sta gtia.colpf2

    // setup buffer
    ldx # (buffer_init_end - buffer_init) - 1
!loop:
    lda buffer_init, x
    sta buffer, x
    dex
    bpl !loop-

    lda # buffer
    sta buffer_start+0
    lda # buffer + (buffer_init_end - buffer_init)
    sta buffer_end+0
    lda # buffer >> 8
    sta buffer_start+1
    sta buffer_end+1

big_loop:
    // check EOF
    lda buffer_start+0
    cmp buffer_end+0
    bne !skip+
    lda buffer_start+1
    cmp buffer_end+1
    bne !skip+
    jmp render // is done -> restart
!skip:

    // read values
    ldy # 0
    lda (buffer_start), y
    sta rend_x
    iny
    lda (buffer_start), y
    sta rend_y
    iny
    lda (buffer_start), y
    lsr
    sta rend_s

    // inc start buffer (since it's read)
    lda buffer_start+0
    ldx buffer_start+1
    jsr inc_buffer
    sta buffer_start+0
    stx buffer_start+1

    lda rend_s
    bne !regular+

    // down to 1 px, fill it
    inc rend_s
    jsr draw_pixels
    jmp big_loop

!regular:
    jsr get_rand2
    sta rend_pos

    lda # 0
    jsr draw_or_push

    // turn
    lda rend_x
    clc
    adc rend_s
    sta rend_x

    lda # 1
    jsr draw_or_push

    // turn
    lda rend_y
    clc
    adc rend_s
    sta rend_y

    lda # 2
    jsr draw_or_push

    // turn
    lda rend_x
    sec
    sbc rend_s
    sta rend_x

    lda # 3
    jsr draw_or_push

    jmp big_loop


    .pc = * "inc_buffer"
inc_buffer:
    clc
    adc # 3
    bcc !skip+
    inx
!skip:
    cmp # buffer_behind_last
    bne !skip+
    cpx # buffer_behind_last >> 8
    bne !skip+
    lda # buffer
    ldx # buffer >> 8
!skip:
    rts


    .pc = * "inc_end_buffer"
inc_end_buffer:
    lda buffer_end+0
    ldx buffer_end+1
    jsr inc_buffer
    sta buffer_end+0
    stx buffer_end+1
    rts


    .pc = * "get_rand2"
get_rand2:
    lda pokey.random
    and # $03
    rts


    .pc = * "draw_or_push"
draw_or_push:
    // A = position
    cmp rend_pos
    bne !push+

    // draw
    jmp draw_pixels

!push:
    // push
    ldy # 0
    lda rend_x
    sta (buffer_end),y
    iny
    lda rend_y
    sta (buffer_end),y
    iny
    lda rend_s
    sta (buffer_end),y
    jmp inc_end_buffer


    .pc = * "buffer init"
buffer_init:
    .byte 0, 0, 64
    .byte 0, 64, 64
    .byte 64, 0, 128
    .byte 192, 0, 64
    .byte 192, 64, 64
buffer_init_end:
