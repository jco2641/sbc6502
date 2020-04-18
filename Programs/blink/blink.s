    .setcpu "65C02"

    .include "via.inc"
    .include "delay.inc"

    .export __STARTUP__ : absolute = 1

    .segment "VECTORS"

    .word $EAEA
    .word init
    .word $EAEA

    .segment "STARTUP"

init:
    cld
    ldx #$FF
    txs

    .segment "CODE"

main:
    lda #$FF
    sta VIA1_DDRA
    sta VIA1_DDRB
    sta VIA2_DDRA
    sta VIA2_DDRB

mainloop:
    lda #$AA
    sta VIA1_PORTA
    sta VIA1_PORTB
    sta VIA2_PORTA
    sta VIA2_PORTB
    lda #$FF
    jsr _delay_ms
    lda #$55
    STA VIA1_PORTA
    sta VIA1_PORTB
    sta VIA2_PORTA
    sta VIA2_PORTB
    lda #$FF
    jsr _delay_ms
    jmp mainloop