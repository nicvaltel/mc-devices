.include "m16def.inc"

;---- Data Segment
.dseg

;---- Code Segment
.cseg

.org 0x000
    rjmp RESET


.org 0x02A
RESET:
    ; Configure Timer0
    ; WGM00=1 WGM01 = 1 => Mode 3 (Fast PWM) 
    ; COMn1:0 = 2 => PWM non-inverting mode (Clear OC0 on compare match, set OC0 at BOTTOM); out on OC0 pin = PB3
    ; CS00 = CS02 = 1 => prescaler = 1/1024
    ldi r16, (1 << WGM00) | (1 << WGM01) | (1 << COM01) | (1 << CS00) | (1 << CS02) 
    out TCCR0, r16

    ; set level in Output Compare Register
    ldi r16, 32
    out OCR0, r16
    ; out on OC0 pin = PB3

    ; set PB3 as output
    ldi r16, (1 << PB3)
    out DDRB, r16

    ; 32.46 -> 261.8

    
MAIN:
    rjmp MAIN


;---- EEPROM Segment
.eseg
