;---- Определяем целевое устройство
	;; .device atmega8
	.include "m8def.inc"

;---- Сегмент данных
	.dseg

;---- Сегмент кода
	.cseg
	.org 0x0000

	clr r16
	ser r17
	out ddrb, r17
	

loop:
	ldi r21, 15 ;; 1
	ldi r22, 1 ;; 1

	rjmp pulse ;; 2
	loop_ret:
	rjmp loop ;; 2

;; one-level t = 4 + 1
;; zero-level t = 4*r21 + 1 = 4*r21 + 1 = 21
;; one-level t = 4*r22 + 2 + 2 + 4 + 1 = 4*r22 + 9 = 13
;; 4*(r22 - 2) + 9 = 4*r22 +1


pulse:
	;; ---- input ---
	;; r21 as zero-level length
	;; r22 as one-level length
	;; ---- preliminarily ----
	;; ddrb shoud be set to 0xff
	;; r16 shoud = 0x00
	;; r17 should = 0xff
	;; ---- output ----
	;; portb - all pins
	;; starts with zero level 

	out portb, r16 ;; 1
	pulse_zero_level:
	dec r21 ;; 1
	cpse r21, r16 ;; 3 -- always 3 clocks because of rjmp takes 2 clocks
	rjmp pulse_zero_level ;; clocks in previous line

	out portb, r17 ;; 1
	pulse_one_level:
	dec r22 ;; 1
	cpse r22, r16 ;; 3
	rjmp pulse_one_level


	rjmp loop_ret ;; 2
	

;---- Сегмент EEPROM
	.eseg
