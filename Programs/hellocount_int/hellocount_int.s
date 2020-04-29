; Testing interrupts
; Fast clock

; Init LCD on VIA1 PORT B and print Hello World
; Count seconds on second line of LCD
; Run timer 1 on VIA 2
; Count in binary on VIA 1 PORT A per timer interrupt

    .setcpu "65C02"

    .include "via.inc"
    .include "delay.inc"
    .include "lcd.inc"
    .include "zeropage.inc"

    .export __STARTUP__ : absolute = 1

    .segment "VECTORS"

    .word $EAEA
    .word init
    .word isr

    .segment "RODATA"
Output:
    .byte "Hello, World!", $00

    .segment "STARTUP"

init:
    cld
    ldx #$FF
    txs
    stz tmp4
    jmp main

    .segment "CODE"

main:
    jsr _lcd_init

    lda #$FF
    sta VIA1_DDRA
    stz VIA1_PORTA

    ; Init timer
    lda #$40                ; Continuous timer 1 no PB7
    sta VIA2_ACR
    lda #$C0
    sta VIA2_IER            ; Enable interrupts from timer 1
    lda #$50
    sta VIA2_T1CL
    lda #$C3
    sta VIA2_T1CH           ; $C350 = 50,000 At 1 MHz is 50 ms
    cli                     ; Enable interrupts

    ; Write to display
    lda #<Output
    ldx #>Output
    jsr _lcd_print

count:
    ldy #$30                ; ASCII 0

countloop:
    lda #$40
    jsr _lcd_set_position   ; Move cursor to first space of line 2
    tya
    cmp #$3A                ; ASCII : (character after 9)
    beq count
    jsr _lcd_write
    iny
    lda #$FA
    jsr _delay_ms           ; $FA = 250 ms
    lda #$FA
    jsr _delay_ms
    lda #$FA
    jsr _delay_ms
    lda #$FA
    jsr _delay_ms           ; 4 times is one second
    jmp countloop

isr:
    pha
    inc tmp4
    lda tmp4
    sta VIA1_PORTA
    lda VIA2_T1CL           ; Reading this resets the IRQ
    pla
    rti
