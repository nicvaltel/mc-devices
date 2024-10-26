; Master CPU - determine PWU width level and send it to slave via SPI
.include "m16def.inc"

.equ MOSI = PB5
.equ MISO = PB6
.equ SCK = PB7
.equ AMPLITUDE_DELTA = 0x100


;---- Data Segment
.dseg

;---- Code Segment
.cseg

.org 0x000
    rjmp RESET

.org 0x012 
    rjmp TIM0_OVF_ISR

.org SPIaddr ; SPIaddr = 0x014
    rjmp SPI_STC_ISR 


.org 0x02A
RESET:
    ldi r16, (1 << MOSI) | (1 << SCK) ; MOSI(PB5) is output ; SCK(PB7) is output
    out ddrb, r16

    
    ldi r16, (1 << SPIE) | (1 << SPE) | (1 << MSTR) ; SPE enable work of SPI;  SPIE enable SPI interrept ; MSTR = 1 => master 
    out SPCR, r16
    ; to set SPI generator divider = 128
    ; ldi r16, (1 << SPR0) | (1 << SPR1)


    ; Configure Timer0
    ; Normal mode
    ; Set no prescaler
    ldi r16,   (1 << CS00)
    out TCCR0, r16

    ; ; Set prescaler to 64
    ; ldi r16,  (1 << CS01) | (1 << CS00)
    ; out TCCR0, r16

    ; ; Set prescaler to 1024p
    ; ldi r16, (1 << CS00) | (1 << CS02)
    ; out TCCR0, r16

    

    ; Enable Timer0 overflow interrupt
    ldi r16, (1 << TOIE0)
    out TIMSK, r16


    ; Enable global interrupts
    sei

    
MAIN:
    ; write data into SPDR, to start SPI Transfer
    ldi r30, 127
    out SPDR, r30
    LOOP:
    rjmp LOOP


; Interrupt Service Routine for SPI Serial Transfer Complete
SPI_STC_ISR:
    in r31, SPDR
    out SPDR, r30
    reti

;Interrupt Service Routine for Timer0 overflow
TIM0_OVF_ISR:
    rcall UPDATE_AMPLITUDE
    reti


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
    mov r16, r30

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
    mov r30, r16

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
