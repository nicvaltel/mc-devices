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
	ser r18
	out ddrc, r17
	
loop:
	ldi r21, 1 ;; 2 + 1 = 2
	inc r18
  out portc, r18
	ldi r22, 1 ;; 2 + 1 = 2

	rjmp pulse ;; 2
;; 8(0) - 8(1)

pulse:
	;; ---- input ---
	;; r21 >= 1 as zero-level length minus 2: t0 = 4*(r21 + 2)
	;; r22 >= 1 as one-level length minus 2: t1  = 4*(r22 + 2)
	;; ---- preliminarily ----
	;; ddrc shoud be set to 0xff
	;; r16 shoud = 0x00
	;; r17 should = 0xff
	;; ---- output ----
	;; portc - all pins
	;; starts with zero level 

	pulse_zero_level:
	dec r21 ;; 1
	cpse r21, r16 ;; 3 -- always 3 clocks because of rjmp takes 2 clocks
	rjmp pulse_zero_level ;; clocks in previous line
	nop
	nop
	nop

	inc r18
	out portc, r18 ;; 1
	pulse_one_level:
	dec r22 ;; 1
	cpse r22, r16 ;; 3
	rjmp pulse_one_level ;; clocks in previous line
	nop
	nop
	nop	

	rjmp loop ;; 2
	

;---- Сегмент EEPROM
	.eseg
