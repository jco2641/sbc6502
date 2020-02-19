
.export _delay_ms

    ; Runs a delay loop. Length in ms = value in register a
    ; 1 MHz clock - 1 us per clock =~ 1000(a) cycles to process loop

_delay_ms:
    phx                 ; 2
    phy                 ; 2
    tax                 ; 2
    ldy #198            ; 2 

loop1:
    dey                 ; 2 
    bne loop1           ; 2 ( +1 if crossing page boundary, +1 if taking branch)

loop2:
    dex                 ; 2
    beq return          ; 2 ( +1 if crossing page boundary, +1 if taking branch)
    nop                 ; 2
    ldy #198            ; 2

loop3:
    dey                 ; 2
    bne loop3           ; 2 ( +1 if crossing page boundary, +1 if taking branch)
    jmp loop2           ; 4

return:
    ply                 ; 2
    plx                 ; 2
    rts                 ; 3 - 7 