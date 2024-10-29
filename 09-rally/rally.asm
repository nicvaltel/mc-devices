;; Rally game
.include "m16def.inc"

;---- Data Segment
.dseg

;---- Code Segment
.cseg


.org 0x000
    rjmp RESET

.org OVF0addr ;; OVF0addr	= 0x0012	; Timer/Counter0 Overflow
    rjmp TIM0_OVF_ISR


.org 0x02A
RESET:
    ; set porta, portb, portc as output (for lcd pins)
    ldi r16, 0xff
    out ddra, r16
    out ddrb, r16
    out ddrc, r16

    ldi r16, 0b00001110
    out ddrd, r16

    

    ; Configure Timer0
    clr r16
    out TCCR0, r16 ; Clear TCCR0 (Normal timer mode)

    ; Set prescaler to 1024
    ldi r16, (1 << CS00) | (1 << CS02)
    out TCCR0, r16

    ; Enable Timer0 overflow interrupt
    ldi r16, (1 << TOIE0)
    out TIMSK, r16

    ; Enable global interrupts
    sei


MAIN:
    ldi r16, 0b00000100
    out portd, r16

    ldi r16, 0b00000001
    out porta, r16
    ldi r16, 0b00000010
    out portb, r16
    ldi r16, 0b00000100
    out portc, r16

    LOOP:
    ; process left-right control keys
    in r16, pind
    sbrs r16, 6 ; Skip if Bit in Register Set => skip if 6 bit is 1 (button released)
    rjmp TURN_LEFT
    sbrs r16, 7 ; Skip if Bit in Register Set => skip if 7 bit is 1 (button released)
    rjmp TURN_RIGHT

    rjmp LOOP

    TURN_LEFT:
    rcall DELAY
    ldi r17, 0b00001110
    lsl r16 ; left shift
    and r16, r17 ; left only player car position
    BREQ LOOP ; if zero flag = 0 then car was on edge, do nothing
    out portd, r16
    rjmp LOOP

    TURN_RIGHT:
    rcall DELAY
    ldi r17, 0b00001110
    lsr r16 ; right shift
    and r16, r17 ; left only player car position
    BREQ LOOP ; if zero flag = 0 then car was on edge, do nothing
    out portd, r16
    rjmp LOOP

    ; TURN_RIGHT:
    ; ldi r17, 0b00001110
    ; and r16, r17 ; left only player car position
    ; lsr r16 ; right shift
    ; sbrc r16, 0; skip if 0th bit = 0
    ; ldi r16, 0b00000010 ; car was on right edge, and right key was pressed, stay at right edge
    ; out portd, r16
    ; rjmp LOOP
    

DELAY:
    push r16
    push r17
    ldi r16, 0xff
    DELAY_LOOP:
    ldi r17, 0xff
    DELAY_SUBLOOP:
    dec r17
    brne DELAY_SUBLOOP
    dec r16
    brne DELAY_LOOP

    pop r17
    pop r16
    ret ; 4cs



; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    push r16
    push r17
    push r18
    in r16, SREG
    push r16

    ldi r18, 1

    ; left shift porta
    in r16, porta
    lsl r16
    
    ; set carry flag to 0 bit
    in r17, SREG
    sbrc r17, 0 ; Skip if Bit in Register Cleared => skip if carry flag is cleared
    or r16, r18 ; set 1 to 0-bit if carry flag is set
    out porta, r16

    ; left shift portb
    in r16, portb
    lsl r16
    
    ; set carry flag to 0 bit
    in r17, SREG
    sbrc r17, 0 ; Skip if Bit in Register Cleared => skip if carry flag is cleared
    or r16, r18 ; set 1 to 0-bit if carry flag is set
    out portb, r16


    ; left shift portc
    in r16, portc
    lsl r16
    
    ; set carry flag to 0 bit
    in r17, SREG
    sbrc r17, 0 ; Skip if Bit in Register Cleared => skip if carry flag is cleared
    or r16, r18 ; set 1 to 0-bit if carry flag is set
    out portc, r16

    pop r16
    out SREG, r16
    pop r18
    pop r17
    pop r16

    reti


;---- EEPROM Segment
.eseg
