.include "m16def.inc"

.equ MOSI = PB5
.equ MISO = PB6
.equ SCK = PB7



;---- Data Segment
.dseg
led_seg_array: .db 1,2,3,4
;; led_seg_array: .byte 8 ;Reserve 8 bytes for array
;;     ; .byte 0b1111110, 0b0110000, 0b1101101, 0b1111001



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
    ; ldi r16, 0b11111100
    ; sts led_seg_array, r16

    ldi r30, low(led_seg_array)
    ldi r31, high(led_seg_array)

    ldi r16, 0b11111100
    st Z, r16
    
    ldi r16, 0b01100000
    inc r30
    st Z, r16

    ldi r16, 0b11011010
    inc r30
    st Z, r16

    ldi r16, 0b11110010
    inc r30
    st Z, r16
    

    
MAIN:
    rjmp MAIN

; Interrupt Service Routine for ADC Conversion Complete
ADC_ISR:

; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:

    reti

; led_seg_array: .db 1, 2, 3, 4, 5, 6, 7, 8, 9


;---- EEPROM Segment
.eseg
