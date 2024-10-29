.include "m16def.inc"

.equ MOSI = PB5
.equ MISO = PB6
.equ SCK = PB7



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
    ; set portb as output
    ldi r16, 0xff
    out ddrb, r16

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
    

    
MAIN:
    ldi r21, 10 ; end of digits, if r20=r21 then LOOP_FROM_0

    LOOP_FROM_0:
    ldi r20, 0

    LOOP:
    rcall DISPLAY_NUMBER
    
    inc r20

    cpse r20, r21
    rjmp LOOP
    
    rjmp LOOP_FROM_0



DISPLAY_NUMBER:
    ; input r20
    ; output portb

    ; read led_seg_array[r20]
    ldi r26, low(led_seg_array)
    ldi r27, high(led_seg_array)

    add r26, r20 ; add array index

    ld r16, X

    out portb, r16

    ret




; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    reti

;---- EEPROM Segment
.eseg
