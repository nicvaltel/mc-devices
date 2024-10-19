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
	out ddrc, r17
	
loop:
	ldi r21, 255 ;; 1 + 1 = 2
  out portc, r16
	ldi r22, 255 ;; 1 + 1 = 2

	rjmp pulse_precision ;; 2
;; 4(0) - 4(1)

pulse_precision:
	;; ---- input ---
	;; r21 as zero-level length minus 1: t0 = 4*(r21 + 1)
	;; r22 as one-level length minus 1: t1  = 4*(r22 + 1)
	;; ---- preliminarily ----
	;; ddrc shoud be set to 0xff
	;; r16 shoud = 0x00
	;; r17 should = 0xff
	;; ---- output ----
	;; portc - all pins
	;; starts with zero level 

	pulse_precision_zero_level:
	dec r21 ;; 1
	cpse r21, r16 ;; 3 -- always 3 clocks because of rjmp takes 2 clocks
	rjmp pulse_precision_zero_level ;; clocks in previous line

	out portc, r17 ;; 1
	pulse_precision_one_level:
	dec r22 ;; 1
	cpse r22, r16 ;; 3
	rjmp pulse_precision_one_level ;; clocks in previous line

	rjmp loop ;; 2
	

;---- EEPROM Segment
	.eseg
