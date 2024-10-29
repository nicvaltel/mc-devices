;; Control 7-segments lcd display. 
;; Invert signal between lcd pins and ground to avoid lcd cells degradation
.include "m16def.inc"

;---- Data Segment
.dseg
led_seg_array: .byte 8 ;Reserve 8 bytes for array

;---- Code Segment
.cseg


.org 0x000
    rjmp RESET

.org OVF0addr ;; OVF0addr	= 0x0012	; Timer/Counter0 Overflow
    rjmp TIM0_OVF_ISR


.org 0x02A
RESET:
    ; set portb as output (for lcd pins)
    ldi r16, 0xff
    out ddrb, r16

    ; set PA0 as output (for lcd ground)
    ldi r16, 1
    out ddra, r16

    ; fill led_seg_array with data
    ldi r26, low(led_seg_array)
    ldi r27, high(led_seg_array)

    ldi r16, 0b01111110 ;0
    st X+, r16
    ldi r16, 0b00110000 ;1
    st X+, r16
    ldi r16, 0b01101101 ;2
    st X+, r16
    ldi r16, 0b01111001 ;3
    st X+, r16
    ldi r16, 0b00110011 ;4
    st X+, r16
    ldi r16, 0b01011011 ;5
    st X+, r16
    ldi r16, 0b01011111 ;6
    st X+, r16
    ldi r16, 0b01110000 ;7
    st X+, r16
    ldi r16, 0b01111111 ;8
    st X+, r16
    ldi r16, 0b01111011 ;9
    st X+, r16


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
    rjmp MAIN


; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    ;; uses r20 for signal digit (r20 shoud contain nuber from 0 to 9)
    push r16
    push r17
    push r18
    push r26
    push r27
    in r16, SREG
    push r16

    ; increment r20

    inc r20
    cpi r20, 10
    breq TIM0_OVF_ISR_SET_DIGIT_TO_0

    TIM0_OVF_ISR_READ_SEG_ARRAY:
    ; read led_seg_array[r20]
    ldi r26, low(led_seg_array)
    ldi r27, high(led_seg_array)

    add r26, r20 ; add array index
    ld r18, X ; save led_seg_array[r20] to r18, but don't load it to portb right now, maybe needs to invert it

    ; load PA0 to r16
    in r16, porta

    ;; change 0 bit in PA0 (ground level)
    ldi r17, 1
    eor r16, r17 
    out porta, r16

    ;; invert lcd pins signal, when ground level = 1 (not 0)
    ldi r17, 0xff
    SBRC r16, 0 ; Skip if Bit in Register Cleared => if PA0 = 1, then do, else skip
    eor r18, r17 ;; invert lcd pins output
    
    out portb, r18

    pop r16
    in r16, SREG
    pop r27
    pop r26
    pop r18
    pop r17
    pop r16
    reti

    TIM0_OVF_ISR_SET_DIGIT_TO_0:
    clr r20
    rjmp TIM0_OVF_ISR_READ_SEG_ARRAY

;---- EEPROM Segment
.eseg
