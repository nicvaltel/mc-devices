;; Spectrum Transformer on Ring Modulator 
;; Radio Mag - 1982/02 page 45
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
    ; set porta as output
    ser r16
    out ddra, r16

    ser r20 ; initial value of r20
    ser r21

    ; Configure Timer0
    clr r16
    out TCCR0, r16 ; Clear TCCR0 (Normal timer mode)

    ; Set prescaler to 8
    ldi r16, (1 << CS01)
    out TCCR0, r16
    ; ; Set prescaler to 1024
    ; ldi r16, (1 << CS00) | (1 << CS02)
    ; out TCCR0, r16

    ; Enable Timer0 overflow interrupt
    ldi r16, (1 << TOIE0)
    out TIMSK, r16

    ; Enable global interrupts
    sei
    

    
MAIN:
    ; in r16, pinb
    ; ; sbrc r20, 0 ; Skip if Bit in Register Cleared => skip if r20_0 = 0
    ; eor r16, r20
    ; out porta, r16


    ; copy input of ADC to output - to DAC
    in r16, pinb
    
    sbrs r20, 0 ; Skip if Bit in Register Set => skip if r20_0 = 1
    rjmp MAIN_FINISH

    ldi r16, 127
    in r17, pinb

    lsr r17 ; = /2
    lsr r17

    add r16, r17

    MAIN_FINISH:
    out porta, r16

    rjmp MAIN



; Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    eor r20, r21  ;; invert r20
    reti

;---- EEPROM Segment
.eseg
