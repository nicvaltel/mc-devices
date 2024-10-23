#include	"/usr/avr/include/avr/io.h"	

/* Секция данных */
	.data

/* Секция кода */
	.section .text

	.org 0x0000

/* Точка входа, обязательная при вызове avr-gcc вместо avr-as */
	.global main

main:

	ldi r16, 10
M1:
	inc r16
	rjmp M1
