.include "m16def.inc"

.equ AMPLITUDE_DELTA = 0x100
.equ CYCLES_COUNTER_1 = 0x101
.equ CYCLES_COUNTER_2 = 0x102
.equ CYCLES_COUNTER_3 = 0x103

;---- Data Segment
.dseg

;---- Code Segment
.cseg

.org 0x000
    rjmp RESET

.org 0x012 
    rjmp TIM0_OVF_ISR


.org 0x02A
RESET:
    ; Configure Timer0
    ; WGM00=1 WGM01 = 1 => Mode 3 (Fast PWM) 
    ; COMn1:0 = 0b10 => PWM non-inverting mode (Clear OC0 on compare match, set OC0 at BOTTOM); out on OC0 pin = PB3
    ; CS00 = 1 => no prescaler
    ldi r16, (1 << WGM00) | (1 << WGM01) | (1 << COM01) | (1 << CS00)

    ; CS00 = CS02 = 1 => prescaler = 1/1024
    ; ldi r16, (1 << WGM00) | (1 << WGM01) | (1 << COM01) | (1 << CS00) | (1 << CS02) 
    out TCCR0, r16

    ; set level in Output Compare Register
    ldi r16, 32
    out OCR0, r16
    ; out on OC0 pin = PB3

    ; set PB3 as output
    ldi r16, (1 << PB3)
    out DDRB, r16

    ; Enable Timer0 overflow interrupt
    ldi r16, (1 << TOIE0)
    out TIMSK, r16

    ; Enable global interrupts
    sei

    
MAIN:
    rjmp MAIN


;Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:

    rcall UPDATE_AMPLITUDE
    reti


    ; ; load CYCLES_COUNTER_1
    ; ldi r27, high(CYCLES_COUNTER_1) ; X = R27:R26
    ; ldi r26, low(CYCLES_COUNTER_1)
    ; ld r16, X

    ; ; increment and save CYCLES_COUNTER_1
    ; inc r16
    ; st X,r16

    ; ; if CYCLES_COUNTER_1 = 10 then call UPDATE_AMPLITUDE
    ; cpi r16, 1
    ; brne FINISH_TIM0_OVF_ISR

    ; rcall UPDATE_AMPLITUDE

    ; FINISH_TIM0_OVF_ISR:
    ; reti

UPDATE_AMPLITUDE:
    push r16
    push r17
    push r18
    push r26
    push r27
    in r16, SREG
    push r16

    ; load AMPLITUDE_DELTA
    ldi r27, high(AMPLITUDE_DELTA) ; X = R27:R26
    ldi r26, low(AMPLITUDE_DELTA)
    ld r17, X

    ; read AMPLITUDE value
    in r16, OCR0

    SBRC r17, 0 ; Skip if Bit in Register Cleared, skip if r17=0
    inc r16 ; if r17 = 1 then inc r16
    
    SBRS r17, 0 ; Skip if Bit in Register is Set, skip if r17=1
    dec r16 ; if r17 = 0 then dec r16

    cpi r16, 0
    breq UPDATE_AMPLITUDE_REACH_LIMIT

    cpi r16, 255
    breq UPDATE_AMPLITUDE_REACH_LIMIT

    rjmp FINISH_UPDATE_AMPLITUDE
    
    UPDATE_AMPLITUDE_REACH_LIMIT:
    ; invert delta
    ldi r18, 1
    eor r17, r18

    ; save new AMPLITUDE_DELTA
    ldi r27, high(AMPLITUDE_DELTA) ; X = R27:R26
    ldi r26, low(AMPLITUDE_DELTA)
    st X, r17

    FINISH_UPDATE_AMPLITUDE:

    ; write  new AMPLITUDE value
    out OCR0, r16

    pop r16
    out SREG, r16
    pop r27
    pop r26
    pop r18
    pop r17
    pop r16

    ret


;---- EEPROM Segment
.eseg
