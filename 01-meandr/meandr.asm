;---- Определяем целевое устройство
	;; .device atmega8
	.include "m8def.inc"

;---- Сегмент данных
	.dseg

;---- Сегмент кода
	.cseg
	.org 0x0000

	clr r16
	ldi r17,0xff
	out ddrb, r17
	

loop:
	out PORTB, r17
	inc r17
	rjmp loop

;---- Сегмент EEPROM
	.eseg
