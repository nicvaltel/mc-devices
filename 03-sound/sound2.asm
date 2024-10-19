;---- Device Setup
	;; .device atmega8
	.include "m8def.inc"

;---- Data Segment
	.dseg

;---- Code Segment
	.cseg
	.org 0x0000

	clr r16
	ser r17
	ldi r31, 20
	ldi r30, 0
	out ddrc, r17
	
loop:
	mov r21, r31 ;; 1
	mov r22, r30 ;; 1
  out portc, r16 ;; 1
	mov r23, r31 ;; 1
	mov r24, r30 ;; 1
	rjmp pulse ;; 2
;; 4(0) - 4(1)

pulse:
	;; ---- input ---
	;; r21 >= 1 as zero-level length minus 1: t0 = 4*(r21 + 1)
	;; r22 >= 1 as one-level length minus 1: t1  = 4*(r22 + 1)
	;; ---- preliminarily ----
	;; ddrc shoud be set to 0xff
	;; r16 shoud = 0x00
	;; r17 should = 0xff
	;; ---- output ----
	;; portc - all pins
	;; starts with zero level 

	inc r21 ;; 1
	inc r22 ;; 1
	pulse_zero_level:
	dec r21 ;; 1
	cpse r21, r16 ;; 3 
	rjmp pulse_zero_level ;; 0
	dec r22 ;; 1
	cpse r22, r16 ;; 3
	rjmp pulse_zero_level ;; 0
	out portc, r17 ;; 1
	nop ;; 1
	;; 4 ... + 1 + 1 + 4*((m + 1) + 256*n) + 4*(n + 1) + 1 + 1
	;; [4] + 4*(m + 1 256*n + n + 1) + 3 + 1
	;; 4(m + 257n + 4) - (n + 1)???

	inc r23 ;; 1
	inc r24 ;; 1
	pulse_one_level:
	dec r23 ;; 1
	cpse r23, r16 ;; 3
	rjmp pulse_one_level ;; 0
	dec r24 ;; 1
	cpse r24, r16 ;; 3
	rjmp pulse_one_level ;; 0
	rjmp loop ;; 2
	nop

	;; 1 + 1 + 4*(m + 256*n) + 4*n + 2 + ... 3 + 1
	;; 4*(m + 1 + 257*n + n) + 4 + 1 + [3]
	;; 4(m + 257n + 4) - (n + 1)???
	

;---- EEPROM Segment
	.eseg
