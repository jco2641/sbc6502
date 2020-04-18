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
    lda #<Output
    ldx #>Output
    jsr _lcd_print

count:
    ldy #$30        ; ASCII 0

countloop:
    lda #$40
    jsr _lcd_set_position
    tya
    cmp #$3A        ; ASCII : (character after 9)
    beq count
    jsr _lcd_write
    iny
    lda #$FA
    jsr _delay_ms
    lda #$FA
    jsr _delay_ms
    lda #$FA
    jsr _delay_ms
    lda #$FA
    jsr _delay_ms
    jmp countloop

end:
    stp