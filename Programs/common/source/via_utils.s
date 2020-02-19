      .include "via.inc"

      .export _via1_init_porta
      .export _via1_init_portb
      .export _via1_output_porta
      .export _via1_output_portb
      ; TODO: More VIA functions
      ; TODO: Times 4 VIA chips
      .code

_via1_init_porta:
      sta VIA1_DDRA
      rts

_via1_init_portb:
      sta VIA1_DDRB
      rts

_via1_output_porta:
      sta VIA1_PORTA
      rts

_via1_output_portb:
      sta VIA1_PORTB
      rts
