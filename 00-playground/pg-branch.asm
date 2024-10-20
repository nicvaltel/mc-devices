.include "m8def.inc"

.dseg

.cseg
.org 0x0000

  clr r16
  ser r17
  out ddrb, r17
  out portb, r17 ;; start

	ldi r18,5 ;; 1
DELAY_LOOP:
  dec r18 ;; 1
  brne DELAY_LOOP ;; 2 cycles if branch taken, 1 if not taken

  out portb, r16 ;; 1
  ;; 1 + (1+2)*4 + 1+1 + 1 = 16

  ser r19


.eseg
