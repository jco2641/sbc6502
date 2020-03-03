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

; LCD Commands list
.export LCD_CMD_CLEAR           = $01
.export LCD_CMD_HOME            = $02
.export LCD_CMD_ENTRY_MODE      = $04
.export LCD_CMD_DISPLAY_MODE    = $08
.export LCD_CMD_CURSOR_SHIFT    = $10
.export LCD_CMD_FUNCTION_SET    = $20
.export LCD_CMD_CGRAM_SET       = $40
.export LCD_CMD_DDRAM_SET       = $80

; Entry mode command parameters
.export LCD_EM_SHIFT_CURSOR     = $00
.export LCD_EM_SHIFT_DISPLAY    = $01
.export LCD_EM_DECREMENT        = $00
.export LCD_EM_INCREMENT        = $02

; Display mode command parameters
.export LCD_DM_CURSOR_NOBLINK   = $00
.export LCD_DM_CURSOR_BLINK     = $01
.export LCD_DM_CURSOR_OFF       = $00
.export LCD_DM_CURSOR_ON        = $02
.export LCD_DM_DISPLAY_OFF      = $00
.export LCD_DM_DISPLAY_ON       = $04

; Function set command parameters
.export LCD_FS_FONT5x8          = $00
.export LCD_FS_FONT5x10         = $04
.export LCD_FS_ONE_LINE         = $00
.export LCD_FS_TWO_LINE         = $08
.export LCD_FS_4_BIT            = $00
.export LCD_FS_8_BIT            = $10

LCD_E  = $80            ; Pin 7
LCD_RW = $40            ; Pin 6
LCD_RS = $20            ; Pin 5

    .segment "CODE"

_lcd_init:
    pha
    jsr _via_init
    lda #15                 ; Minimum 15 ms after power up
    jsr _delay_ms
    lda #(LCD_CMD_FUNCTION_SET | LCD_FS_8_BIT | LCD_FS_TWO_LINE | LCD_FS_FONT5x8 )
    jsr _lcd_send_command
    lda #5                  ; Minimum 4.1 ms after previous command
    jsr _delay_ms
    lda #(LCD_CMD_FUNCTION_SET | LCD_FS_8_BIT | LCD_FS_TWO_LINE | LCD_FS_FONT5x8 )
    jsr _lcd_send_command
    lda #1                  ; Minimum 100 us after previous command - still have to use delay
    jsr _delay_ms
    lda #(LCD_CMD_FUNCTION_SET | LCD_FS_8_BIT | LCD_FS_TWO_LINE | LCD_FS_FONT5x8 )
    jsr _lcd_send_command   ; We can check busy flag hereafter
    lda #( LCD_CMD_DISPLAY_MODE | LCD_DM_DISPLAY_ON | LCD_DM_CURSOR_ON | LCD_DM_CURSOR_NOBLINK )
    jsr _lcd_command        ; Switch to subroutine that waits on LCD busy
    lda #( LCD_CMD_ENTRY_MODE | LCD_EM_INCREMENT | LCD_EM_SHIFT_CURSOR )
    jsr _lcd_command
    lda #LCD_CMD_CLEAR
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
    lda #$80                ; Set accumulator bit 7 - mask for BIT instruction
    bit LCD_DATA            ; AND value read with A. Puts bit 7 of result into negative flag.
    bmi _checkloop          ; Loop if we found a 1 in negative flag - the LCD is busy

    lda LCD_CONTROL         ; LCD is not busy
    eor #LCD_E
    eor #LCD_RW
    sta LCD_CONTROL
    lda #$FF
    sta LCD_DATA_DDR
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
