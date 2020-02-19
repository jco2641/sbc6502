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
    sta VIA1_DDRB
    lda #$01

switchleft:
    rol A

leftloop:
    rol A
    bcs switchright
    sta VIA1_PORTB
    pha
    lda #80            ; milliseconds
    jsr _delay_ms
    pla
    jmp leftloop

switchright:
    ror A

rightloop:
    ror A
    bcs switchleft
    sta VIA1_PORTB
    pha
    lda #80            ; milliseconds
    jsr _delay_ms
    pla
    jmp rightloop

