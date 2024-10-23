.include "m8def.inc"

;---- Data Segment
.dseg

;---- Code Segment
.cseg
.org 0x0000
rjmp RESET

MAIN:
    ldi r20,0xff
	out ddrb, r20

LOOP:
    out portb, r17
    inc r17
    rjmp LOOP

RESET:
    clr r16
    ser r17
    rjmp MAIN

;---- EEPROM Segment
.eseg
