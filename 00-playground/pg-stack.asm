.include "m8def.inc"

.dseg

.cseg
.org 0x0000
  rjmp RESET


.org 0x013 
RESET:
    ldi r16, high(RAMEND)
    out sph, r16
    ldi r16, low(RAMEND)
    out spl, r16

MAIN:
    ldi r16, 16
    push r16
    ldi r16, 17
    push r16
    ldi r16, 18
    push r16

    ldi r17, 0xA
    LOOP:
    dec r17
    brne LOOP

    pop r20

    ldi r17, 0xff
    LOOP1:
    dec r17
    brne LOOP1



.eseg