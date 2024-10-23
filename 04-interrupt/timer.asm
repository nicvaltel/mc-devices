.include "m8def.inc"

;---- Data Segment
.dseg

    .equ HALF_PERIOD = 0x0100
    .equ PREV_KEY_STATE = 0x0101
    .equ BUTTON_PIN = 32 ; 0b00100000

;---- Code Segment
.cseg

.org 0x000
    rjmp RESET

.org OVF0addr ;; .equ	OVF0addr	= 0x0009	; Timer/Counter0 Overflow
    rjmp TIM0_OVF_ISR


.org 0x013 
RESET:

    ;; temp
    ldi r16, 1
    ldi r17, 255
    sub r17, r16
    out TCNT0, r17
    ;; temp`

    ; save state of pressed key
    in r16, pinb
    ldi r17, BUTTON_PIN
    and r16, r17 ; only BUTTON_PIN left
    ldi r27, high(PREV_KEY_STATE) ; X = R27:R26
    ldi r26, low(PREV_KEY_STATE)
    st X, r16 ; save state of BUTTON_PIN


    ; set PB0 as output
    ldi r16, (1 << PB0)
    out DDRB, r16


    ; Configure Timer0
    clr r16
    out TCCR0, r16 ; Clear TCCR0 (Normal mode)

    ; Set prescaler to 1024
    ldi r16, (1 << CS00) | (1 << CS02)
    out TCCR0, r16

    ; ; Set prescaler to 8
    ; ldi r16, (1 << CS01)
    ; out TCCR0, r16

    ; ; Set prescaler to 64
    ; ldi r16,  (1 << CS01) | (1 << CS00)
    ; out TCCR0, r16

    ; set initial half_period
    ldi r16, 1
    ldi r27, high(HALF_PERIOD) ; X = R27:R26
    ldi r26, low(HALF_PERIOD)
    st X, r16 ; Initial half_period = 1

    ; count not from 0, but from 255 - HALF_PERIOD
    ser r17
    sub r17, r16
    out TCNT0, r17
    
    ; Enable Timer0 overflow interrupt
    ldi r16, (1 << TOIE0)
    out TIMSK, r16

    ; Enable global interrupts
    sei
    
MAIN:
    ; read PB5 state
    in r16, pinb
    ldi r17, BUTTON_PIN ; 0b00100000
    and r16, r17 ; only BUTTON_PIN left

    ; load prev state of PB5
    ldi r27, high(PREV_KEY_STATE) ; X = R27:R26
    ldi r26, low(PREV_KEY_STATE)
    ld r17, X

    ; compare new state of PB5 with old one
    sub r16, r17
    brne KEY_PRESSED

    rjmp MAIN

; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    push r16
    push r17
    push r26
    push r27
    in r16, SREG
    push r16

    in r16, PORTB
    ldi r17, 1
    eor r16, r17 ; invert 0 bit
    out PORTB, r16

    ; load half_period
    ldi r27, high(HALF_PERIOD) ; X = R27:R26
    ldi r26, low(HALF_PERIOD)
    ld r16, X

    ; count not from 0, but from 255 - HALF_PERIOD
    ser r17
    sub r17, r16
    inc r17 ;; this increment fix bug with last digit at coping to TCNT0
    out TCNT0, r17

    pop r16
    out SREG, r16
    pop r27
    pop r26
    pop r17
    pop r16
    reti


KEY_PRESSED:

    ; 10ms delay for bouncing
    ldi r17, 40
    KEY_PRESSED_DELAY_LOOP:
    ser r16
    KEY_PRESSED_DELAY_SUBLOOP:
    dec r16
    brne KEY_PRESSED_DELAY_SUBLOOP
    dec r17
    brne KEY_PRESSED_DELAY_LOOP

    ; Increment period time
    ldi r27, high(HALF_PERIOD) ; X = R27:R26
    ldi r26, low(HALF_PERIOD)
    ld r16, X

	lsl r16 ; r16 <- r16 * 2 
    clr r17
    eor r16, r17
    brne KEY_PRESSED_SAVE_NEW_PERIOD
    ldi r16, 1 ; if r16 = 0, then r16 = 1

    KEY_PRESSED_SAVE_NEW_PERIOD:
    ldi r27, high(HALF_PERIOD) ; X = R27:R26
    ldi r26, low(HALF_PERIOD)
    st X, r16 ; save new period

    ; save state of pressed key
    in r16, pinb
    ldi r17, 32 ; 0b00100000
    and r16, r17 ; only PB5 left
    ldi r27, high(PREV_KEY_STATE) ; X = R27:R26
    ldi r26, low(PREV_KEY_STATE)
    st X, r16 ; save state of PB5

    rjmp MAIN


;---- EEPROM Segment
.eseg
