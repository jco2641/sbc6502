; Run an HD44780 driven LCD in 4 bit mode

.export _lcd_init
.export _lcd_write
.export _lcd_print
.export _lcd_clear
.export _lcd_get_position
.export _lcd_set_position
.export _lcd_backspace
.export _lcd_entry_mode
.export _lcd_display_mode

.include "via.inc"
.include "delay.inc"
.include "zeropage.inc"

LCD_PORT = VIA1_PORTB
LCD_PORT_DDR = VIA1_DDRB

; LCD Commands list
LCD_CMD_CLEAR           = $01
LCD_CMD_HOME            = $02
LCD_CMD_ENTRY_MODE      = $04
LCD_CMD_DISPLAY_MODE    = $08
LCD_CMD_CURSOR_SHIFT    = $10
LCD_CMD_FUNCTION_SET    = $20
LCD_CMD_CGRAM_SET       = $40
LCD_CMD_DDRAM_SET       = $80

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
LCD_FS_FONT5x8          = $00
LCD_FS_FONT5x10         = $04
LCD_FS_ONE_LINE         = $00
LCD_FS_TWO_LINE         = $08
LCD_FS_4_BIT            = $00
LCD_FS_8_BIT            = $10

; VIA Pin   |   LCD Pin
; 10 PB0        11 D4
; 11 PB1        12 D5
; 12 PB2        13 D6
; 13 PB3        14 D7
; 14 PB4        4  RS
; 15 PB5        5  RW
; 16 PB6        6  E
; 17 PB7        NC

LCD_E  = $40            ; Pin 6
LCD_RW = $20            ; Pin 5
LCD_RS = $10            ; Pin 4

    .segment "CODE"

; Init by command on Data sheet p 46
; 1. >15 ms after power, send upper 4 of function set interface 8 bit ($30) - so write $03 to port
; 2. >4.1 ms later, send same again
; 3. >100us later, send same again
; 4. Send upper 4 of function set interface 4 bit ($20) - write $02 to port, start checking busy flag
; 5. Send whole function set command
; 6-8. Send rest of initialization

_lcd_init:
    pha
    jsr _via_outmode
    lda #$FF
    sta VIA1_DDRA
    lda #20
    jsr _delay_ms
    lda #$03
    jsr _lcd_send_nibble        ; 1
    lda #5
    jsr _delay_ms
    lda #$03
    jsr _lcd_send_nibble        ; 2
    lda #1
    jsr _delay_ms
    lda #$03
    jsr _lcd_send_nibble        ; 3
    lda #1
    jsr _delay_ms
    lda #$02
    jsr _lcd_send_nibble        ; 4
    lda #1
    jsr _delay_ms
    lda #( LCD_CMD_FUNCTION_SET | LCD_FS_4_BIT | LCD_FS_TWO_LINE | LCD_FS_FONT5x8 )                 ; $28
    jsr _lcd_command            ; 5
    lda #( LCD_CMD_DISPLAY_MODE | LCD_DM_DISPLAY_ON | LCD_DM_CURSOR_ON | LCD_DM_CURSOR_NOBLINK )    ; $0E
    jsr _lcd_command            ; 6
    lda #( LCD_CMD_ENTRY_MODE | LCD_EM_INCREMENT | LCD_EM_SHIFT_CURSOR )                            ; $06
    jsr _lcd_command            ; 7
    lda #LCD_CMD_CLEAR                                                                              ; $00
    jsr _lcd_command            ; 8
    pla
    rts

; LCD Write accepts a single character in the accumulator
; and outputs that character to the current positon on the screen
_lcd_write:
    pha
    jsr _lcd_wait_busy
    pla
    jsr _lcd_send_data
    rts

; LCD Print accepts a pointer in A,X and prints the string at that address
_lcd_print:
    sta lcdstring
    stx lcdstring+1
    phy
    ldy #$00
_lcd_print_loop:
    lda (lcdstring),Y
    beq _lcd_print_end
    jsr _lcd_write
    iny
    bra _lcd_print_loop
_lcd_print_end:
    ply
    rts

_lcd_clear:
    pha
    lda #LCD_CMD_CLEAR
    jsr _lcd_send_command
    pla
    rts

; get current value in LCD address counter (current DDRAM address)
_lcd_get_position:
    jsr _via_checkmode
    lda #LCD_RW
    sta LCD_PORT
    jsr _lcd_read_data
    lda ptr3
    and #$7F    ; value is 7 bits, 8th bit is busy flag
    stz LCD_PORT
    pha
    jsr _via_outmode
    pla
    rts

_lcd_set_position:
    ora #LCD_CMD_DDRAM_SET
    jsr _lcd_command
    rts

_lcd_backspace:
    pha
    jsr _lcd_get_position
    beq _backspacedone      ; Do nothing if position is 0
    cmp #$40
    beq _backspacedone      ; Do nothing if position is $40
    dec A
    jsr _lcd_set_position
_backspacedone:
    pla
    rts

; set entry mode parameters
_lcd_entry_mode:
    ora #LCD_CMD_ENTRY_MODE
    jsr _lcd_send_command
    rts

; set display mode parameters
_lcd_display_mode:
    ora #LCD_CMD_DISPLAY_MODE
    jsr _lcd_send_command
    rts

; ==== Internal functions

; Send a byte in command mode (RS bit unset)
_lcd_command:
    pha
    jsr _lcd_wait_busy
    pla
    jsr _lcd_send_command
    rts

; Polls until LCD busy flag is cleared
_lcd_wait_busy:
    jsr _via_checkmode
    lda #LCD_RW
    sta LCD_PORT
_checkloop:
    jsr _lcd_read_data
    bbs7 tmp3,_checkloop    ; Busy, check again
                            ; Not busy
    stz LCD_PORT            ; Clean up
    jsr _via_outmode        ; Set port back to output
    rts

; Reads busy flag and current DDRAM address, store in tmp3
_lcd_read_data:
    lda #( LCD_E | LCD_RW )
    sta LCD_PORT            ; Enable lcd
    lda LCD_PORT            ; Read data
    and #$0F                ; Keep data lines
    sta tmp1
    lda #LCD_RW
    sta LCD_PORT            ; Disable
    lda #( LCD_E | LCD_RW )
    sta LCD_PORT            ; Enable 2nd cycle
    lda LCD_PORT            ; Read data
    and #$0F
    sta tmp2
    lda #LCD_RW
    sta LCD_PORT            ; Disable
    lda tmp1
    asl A
    asl A
    asl A
    asl A
    ora tmp2
    sta tmp3
    rts

; Send an LCD command byte
_lcd_send_command:
    pha                     ; Save value
    lsr A                   ; Shift upper bits down 4
    lsr A                   ; LSR stuffs zero into msb
    lsr A                   ; instead of carry flag
    lsr A
    jsr _lcd_send_nibble    ; Send upper 4 bits
    pla
    and #$0F                ; Clear upper bits
    jsr _lcd_send_nibble    ; Send lower 4 bits
    rts

; Send an LCD data byte
_lcd_send_data:
    pha                     ; Save value
    lsr A
    lsr A
    lsr A
    lsr A
    ora #LCD_RS
    jsr _lcd_send_nibble    ; Send upper 4 bits
    pla
    and #$0F
    ora #LCD_RS
    jsr _lcd_send_nibble    ; Send lower 4 bits
    rts

; Send 4 bits to LCD
_lcd_send_nibble:
    pha
    sta LCD_PORT            ; Write value
    ora #LCD_E
    sta LCD_PORT            ; Write value with E line set
    pla
    sta LCD_PORT            ; Write value
    rts

_via_outmode:
    lda #$FF
    sta LCD_PORT_DDR
    rts

_via_checkmode:
    lda #$F0
    sta LCD_PORT_DDR
    rts
