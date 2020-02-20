    .setcpu "65C02"

    .include "via.inc"
    .include "delay.inc"
    .include "lcd.inc"

    .export __STARTUP__ : absolute = 1

    .segment "VECTORS"

    .word $EAEA
    .word init
    .word $EAEA

    .segment "RODATA"
Output:
    .byte "Hello, World!", $00

    .segment "STARTUP"

init:
    cld
    ldx #$FF
    txs

    .segment "CODE"

main:
    jsr _lcd_init
    ldx #$00
    
mainloop:
    lda Output,x
    beq end
    jsr _lcd_write
    inx
    jmp mainloop

end:
    stp