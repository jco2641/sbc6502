; Run an HD44780 driven LCD in 8 bit mode
; Assumes LCD did not initialize itself on power up

.export _lcd_init
.export _lcd_command
.export _lcd_write

.include "via.inc"
.include "delay.inc"

LCD_DATA = VIA1_PORTB
LCD_CONTROL = VIA1_PORTA
LCD_DATA_DDR = VIA1_DDRB
LCD_CONTROL_DDR = VIA1_DDRA

LCD_E  = $80            ; Pin 7
LCD_RW = $40            ; Pin 6
LCD_RS = $20            ; Pin 5

    .segment "CODE"

_lcd_init:
    pha
    jsr _via_init
    lda #15                 ; Minimum 15 ms after power up
    jsr _delay_ms
    lda #$38                ; LCD Function set 8 bit interface, 2 lines, 5x8 font
    jsr _lcd_send_command
    lda #5                  ; Minimum 4.1 ms after previous command
    jsr _delay_ms
    lda #$38                ; Same Function set
    jsr _lcd_send_command
    lda #1                  ; Minimum 100 us after previous command - still have to use delay
    jsr _delay_ms
    lda #$38                ; Same Function set
    jsr _lcd_send_command   ; We can check busy flag hereafter
    lda #$0E                ; Display on, cursor on, no blink
    jsr _lcd_command        ; Switch to subroutine that waits on LCD busy
    lda #$06                ; Increment display position, no shift
    jsr _lcd_command
    lda #$01                ; Clear & Home display
    jsr _lcd_command
    pla
    rts

_lcd_command:
    jsr _lcd_wait_busy
    jsr _lcd_send_command
    rts

_lcd_write:
    jsr _lcd_wait_busy
    jsr _lcd_send_data
    rts

_lcd_wait_busy:
    pha
    lda #$7F
    sta LCD_DATA_DDR        ; Toggle data port pin 7 to input

_checkloop:
    lda LCD_CONTROL
    ora #LCD_RW
    eor #LCD_E
    sta LCD_CONTROL
    ora #LCD_E
    sta LCD_CONTROL
    lda #$80
    bit LCD_DATA            ; AND value read with A. Puts bit 7 of result into negative flag.
    bmi _checkloop          ; Loop if we found a 1 in negative flag - the LCD is busy
    lda LCD_CONTROL
    eor #LCD_E
    eor #LCD_RW
    sta LCD_CONTROL
    lda #$FF
    sta LCD_DATA_DDR        ; Put pin back to output
    pla
    rts

_lcd_send_command:
    sta LCD_DATA
    lda LCD_CONTROL
    ora #LCD_E
    sta LCD_CONTROL
    eor #LCD_E
    sta LCD_CONTROL
    rts

_lcd_send_data:
    sta LCD_DATA
    lda LCD_CONTROL
    pha
    ora #LCD_RS
    sta LCD_CONTROL
    ora #LCD_E
    sta LCD_CONTROL
    eor #LCD_E
    sta LCD_CONTROL
    pla
    sta LCD_CONTROL
    rts

_via_init:
    lda #$FF
    sta LCD_DATA_DDR
    lda LCD_CONTROL_DDR
    ora #( LCD_E | LCD_RS | LCD_RW )
    sta LCD_CONTROL_DDR
    lda #$CC
    sta VIA1_PCR
    stz VIA1_ACR
    rts
