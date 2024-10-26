; Slave CPU - generates PWM with width level defined by master via SPI
.include "m16def.inc"

.equ MOSI = PB5
.equ MISO = PB6
.equ SCK = PB7

;---- Data Segment
.dseg

;---- Code Segment
.cseg

.org 0x000
    rjmp RESET

; .org 0x012 
;     rjmp TIM0_OVF_ISR

.org SPIaddr ; SPIaddr = 0x014
    rjmp SPI_STC_ISR 




.org 0x02A
RESET:
    ldi r16, (1 << PB3) | (1 << MISO) ; MISO(PB5) is output ; set PB3 as output (for PWM)
    out ddrb, r16

    ldi r16, (1 << SPIE) | (1 << SPE) | (0 << MSTR) ; SPE enable work of SPI;  SPIE enable SPI interrept ; MSTR = 0 => slave 
    out SPCR, r16
    ; to set SPI generator divider = 128
    ; ldi r16, (1 << SPR0) | (1 << SPR1)



    ; Configure Timer0
    ; WGM00=1 WGM01 = 1 => Mode 3 (Fast PWM) 
    ; COMn1:0 = 0b10 => PWM non-inverting mode (Clear OC0 on compare match, set OC0 at BOTTOM); out on OC0 pin = PB3
    ; CS00 = 1 => no prescaler
    ldi r16, (1 << WGM00) | (1 << WGM01) | (1 << COM01) | (1 << CS00)

    ; CS00 = CS02 = 1 => prescaler = 1/1024
    ; ldi r16, (1 << WGM00) | (1 << WGM01) | (1 << COM01) | (1 << CS00) | (1 << CS02) 
    out TCCR0, r16

    ; set default level in Output Compare Register
    ldi r16, 127
    out OCR0, r16
    ; out on OC0 pin = PB3


    ; ; Enable Timer0 overflow interrupt
    ; ldi r16, (1 << TOIE0)
    ; out TIMSK, r16
    

    ; Enable global interrupts
    sei
    


MAIN:
    rjmp MAIN

; ;Interrupt Service Routine for Timer0 overflow - do nothing, all updates takes place in SPI Interrupt
; TIM0_OVF_ISR:
;     reti


; Interrupt Service Routine for SPI Serial Transfer Complete
SPI_STC_ISR:
    in r31, SPDR

    ; save new PWM width level in Output Compare Register
    out OCR0, r31
    reti


;---- EEPROM Segment
.eseg
