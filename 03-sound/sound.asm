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
	ldi r31, 1
	out ddrc, r17
	out ddrb, r16
	in r25, pinb
	
loop:
	in r26, pinb
	eor r26, r25
	brne key_pressed 

	mov r21, r31 ;; 1
  out portc, r16 ;; 1
	mov r22, r31 ;; 1
	rjmp pulse ;; 2
;; [3] + 40n + 1 (0) = [2] + 40n + 2 (1)

pulse:
	;; ---- input ---
	;; r21 >= 1 as zero-level length: t0 = 40*r21 + 3
	;; r22 >= 1 as one-level length: t1  = 40*r22 + 3
	;; ---- preliminarily ----
	;; ddrc shoud be set to 0xff
	;; r16 shoud = 0x00
	;; r17 should = 0xff
	;; ---- output ----
	;; portc - all pins
	;; starts with zero level 

	
	pulse_zero_level:	
	;; 37 cycles delay
	nop
	ldi r18, 12 ;; 1 + 1 + 12*3 - 1 = 37
	pulse_zero_delay:
	dec r18 ;; 1
	brne pulse_zero_delay ;; 2/1
	dec r21 ;; 1
	brne pulse_zero_level
	out portc, r17 ;; 1
	;; [x] + 1 + (37 + 3)*n - 1 + 1 = [3] + 40n + 1

	pulse_one_level:
	;; 37 cycles delay
	nop
	ldi r18, 12 ;; 1 + 1 + 12*3 - 1 = 37
	pulse_one_delay:
	dec r18
	brne pulse_one_delay
	dec r22 ;; 1
	brne pulse_one_level


	rjmp loop ;; 2
	;; 1 + (37 + 3)*n - 1 + 2 + [y] = [2] + 40n + 2

key_pressed:
	eor r25, r26
	ldi r18, 1000 ;; 1 + 1 + 12*3 - 1 = 37
	key_pressed_delay:
	dec r18 ;; 1
	brne key_pressed_delay ;; 2/1
	;; add r31,r31
	rol r31
	rjmp loop

;---- EEPROM Segment
	.eseg
