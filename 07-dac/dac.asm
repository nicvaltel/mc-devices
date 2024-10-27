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

.org OVF0addr ;; OVF0addr	= 0x0012	; Timer/Counter0 Overflow
    rjmp TIM0_OVF_ISR

.org ADCCaddr ; = 0x001c ; ADC Conversion Complete
    rjmp ADC_ISR


.org 0x02A
RESET:
    ; enable ADC
    ; input = ADC5, via ADMUX registry
    ldi r16, (1 << MUX0) | (1 << MUX2) ; MUX0 = MUX2 = 1 for ADC5 (PA5) as input of DAC
    out ADMUX, r16

    ; ADIE - enable DAC interrupt 
    ; ADPS1-0 = 1 => freq prescaler = 1/8 (out freq must be <= 200kHz)
    ldi r16, (1 << ADIE) | (1 << ADPS1) | (1 << ADPS0) 
    out ADCSRA, r16


    ; Configure Timer0
    ; Set prescaler to 8
    ldi r16, (1 << CS01)
    out TCCR0, r16
    
    ; Enable Timer0 overflow interrupt
    ldi r16, (1 << TOIE0)
    out TIMSK, r16


    ; Enable global interrupts
    sei


    
MAIN:
    rjmp MAIN

; Interrupt Service Routine for ADC Conversion Complete
ADC_ISR:
    ; read result of DAC. First step ADCL need to be reeded. Only after that reed ADCH
    in r30, ADCL
    in r31, ADCH
    reti


; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    push r16
    push r17
    in r16, SREG
    push r16

    ; ; prepare to sleep in idle mode
    ; ldi r16, (1 << SE) | (1 << SM0) ; sleep enable ; SM0 = 1 => ADC Noise Reduction
    ; out MCUCR, r16
    
    ; Start new ADC
    in r17, ADCSRA; get current state of ADCSRA reg
    ldi r16, (1 << ADEN) | (1 << ADSC) ; ADEN enable DAC ; ADSC - start DAC
    or r16, r17 ; take into account previous ADCSRA state
    out ADCSRA, r16

    ; ; start sleep
    ; sleep
    ; ; ATmega16 will automatically wake up from sleep mode when the ADC conversion completes. In ADC Noise Reduction mode, the microcontroller enters sleep mode while the ADC is still active. When the conversion finishes, the ADC Interrupt Flag (ADIF) is set, and the microcontroller wakes up from sleep.

    inc r29

    pop r16
    out SREG, r16
    pop r17
    pop r16
    reti


;---- EEPROM Segment
.eseg
