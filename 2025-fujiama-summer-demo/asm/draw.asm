    .pc = * "draw_pixels"
draw_pixels:
    ldx # 60
!loop:
    dex
    bne !loop-

    // calc ptr (mult 4)
    // ***yyyyy.yyxxxxxx
    lda rend_y
    asl
    asl
    asl
    asl
    asl
    asl
    sta draw_ptr+0
    lda rend_x
    lsr
    lsr
    ora draw_ptr+0
    sta draw_ptr+0
    lda rend_y
    lsr
    lsr
    ora # screen >> 8
    sta draw_ptr+1

    // pick color
    jsr get_rand2
    sta draw_color

    // check size
    lda rend_s
    cmp # 1
    beq draw_pixels1
    cmp # 2
    beq draw_pixels2

    .pc = * "draw_pixels 4"
draw_pixels4:
    // draw a multiple of 4
    sta draw_lines
    lsr
    lsr
    sta draw_chars

    // multiply color
    ldy draw_color
    lda color_pixel4, y
    sta draw_color

!line_begin_loop:
    lda draw_color
    ldy draw_chars
!line_loop:
    dey
    bmi !end_line+

    sta (draw_ptr), y
    jmp !line_loop-


!end_line:
    lda draw_ptr+0
    clc
    adc # $40
    sta draw_ptr+0
    bcc !skip+
    inc draw_ptr+1
!skip:
    dec draw_lines
    bne !line_begin_loop-

    rts


    .pc = * "draw_pixels 2"
draw_pixels2:
    lda rend_x
    lsr
    and # $01
    sta draw_mask

    lda draw_color
    asl
    ora draw_mask
    tax
    lda color_pixel2, x
    sta draw_color

    ldx draw_mask
    lda mask_pixel2, x
    sta draw_mask

    ldy # 0
    lda (draw_ptr), y
    and draw_mask
    ora draw_color
    sta (draw_ptr), y

    ldy # 64
    lda (draw_ptr), y
    and draw_mask
    ora draw_color
    sta (draw_ptr), y

    rts


    .pc = * "draw_pixels 1"
draw_pixels1:
    lda rend_x
    and # $03
    sta draw_mask

    lda draw_color
    asl
    asl
    ora draw_mask
    tax
    lda color_pixel1, x
    sta draw_color

    ldx draw_mask
    lda mask_pixel1, x
    sta draw_mask

    ldy # 0
    lda (draw_ptr), y
    and draw_mask
    ora draw_color
    sta (draw_ptr), y

    rts


    .pc = * "draw_pixels 4 data"
color_pixel4:
    .byte $00, $55, $aa, $ff


    .pc = * "draw_pixels 2 data"
color_pixel2:
    .byte $00, $00
    .byte $50, $05
    .byte $a0, $0a
    .byte $f0, $0f
mask_pixel2:
    .byte $0f, $f0


    .pc = * "draw_pixels 1 data"
color_pixel1:
    .byte $00, $00, $00, $00
    .byte $40, $10, $04, $01
    .byte $80, $20, $08, $02
    .byte $c0, $30, $0c, $03
mask_pixel1:
    .byte $3f, $cf, $f3, $fc
