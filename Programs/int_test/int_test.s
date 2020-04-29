; Interrupt testing
; Written for slow clock

; VIA 1 Port A cycles AA / 55 alternating patterns
; VIA 2 Timer 1 is run in one-shot mode
; VIA 2 PB7 will set to indicate time out 
; VIA 2 PB7 will reset when timer is restarted
; VIA 2 PB6 is toggled on timer interrupt
; Interrupt routine will restart timer

    .setcpu "65C02"

    .include "via.inc"

    .export __STARTUP__ : absolute = 1

    .segment "VECTORS"

    .word $EAEA
    .word init
    .word handle_irq

    .segment "STARTUP"

init:
    sei                 ; Disable interrupts
    cld
    ldx #$FF
    txs
    jmp main

    .segment "CODE"

main:
    lda #$FF
    sta VIA1_DDRA
    sta VIA2_DDRB
    jsr timerinit
    cli                 ; Enable interrupts on cpu

mainloop:
    lda #$AA
    sta VIA1_PORTA
    lda #$55
    STA VIA1_PORTA
    jmp mainloop

handle_irq:
    pha
    lda VIA2_PORTB
    eor #%01000000      ; Toggle PB6 in ISR
    sta VIA2_PORTB
    lda VIA2_T1CL       ; Read T1CL to reset timer
    jsr timerreinit
    pla
    rti

timerinit:
    lda #$80            ; Timer 1 one shot mode set pb7 on timeout
    sta VIA2_ACR
    lda #$A0            ; Enable interrupts, enable timer 1 interrupt
    sta VIA2_IER
timerreinit:
    lda #100            ; 100 clocks
    sta VIA2_T1CL
    stz VIA2_T1CH
    rts
