.include "m8def.inc"
.dseg

.cseg
.org 0x0000
  rjmp RESET

.org 0x013 
RESET:
    ; ldi r16, high(RAMEND)
    ; out sph, r16
    ; ldi r16, low(RAMEND)
    ; out spl, r16

MAIN:
    clr r16
    out ddrb, r16
    
    ser r16
    out ddrc, r16

    ldi r16, 7
    out portb, r16

    ser r16
    out portc, r16

    loop:
    rjmp loop


.eseg