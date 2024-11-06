;; Radio Mag - 1982/04 page 18
.include "m16def.inc"

.equ TIMER_COUNTER = 0x101
.equ SOUND_SIGNAL = 0x102
.equ CURRENT_LITERA_CODE = 0x110
.equ ALPHABET = 0x130
.equ MESSAGE = 0x170


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
    rcall INIT_ALPHABET
    rcall INIT_MESSAGE

    ldi r27, high(MESSAGE)
    ldi r26, low(MESSAGE)
    inc r26
    inc r26
    inc r26
    rjmp LOAD_LITERA

    ; set SOUND_SIGNAL = 0
    ldi r27, high(SOUND_SIGNAL) ; X = R27:R26
    ldi r26, low(SOUND_SIGNAL)
    clr r16
    st X,r16

    ; set TIMER_COUNTER = 0
    ldi r27, high(TIMER_COUNTER) ; X = R27:R26
    ldi r26, low(TIMER_COUNTER)
    clr r16
    st X,r16

    ; set porta as output
    ser r16
    out ddra, r16


    ; Configure Timer0
    ; Set no prescaler
    ldi r16,   (1 << CS00)
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
    push r16
    push r26
    push r27
    in r16, SREG
    push r16

    ; load TIMER_COUNTER
    ldi r27, high(TIMER_COUNTER) ; X = R27:R26
    ldi r26, low(TIMER_COUNTER)
    ld r16, X

    ; increment timer counter
    inc r16
    st X, r16

    cpi r16, 9 ;; check if max timer counter = 9
    brne TIM0_OVF_ISR_FINISH ; if timer counter /= 9 - goto finish
    ; else clear timer counter and invert sound signal

    ; clear timer counter
    clr r16
    st X, r16 

    ; load SOUND_SIGNAL
    ldi r27, high(SOUND_SIGNAL) ; X = R27:R26
    ldi r26, low(SOUND_SIGNAL)
    ld r16, X

    ; save inverted SOUND_SIGNAL
    com r16
    st X, r16

    out porta, r16

    TIM0_OVF_ISR_FINISH:
    pop r16
    out SREG, r16
    pop r27
    pop r26
    pop r16

    reti


LOAD_LITERA:
    ; input:
    ; r26 : low(pointer to letter in MESSAGE)
    ; r27 : hight(pointer to letter in MESSAGE)
    ; output - save one letter from MESSAGE to CURRENT_LITERA_CODE:
    ; CURRENT_LITERA_CODE have array of 1 or 0, ends with 0xff (when end will be reached run LOAD_LITERA again)

    push r16
    push r17
    push r19
    push r20
    push r21
    in r16, SREG
    push r16

    ld r16, X ; load litera from MESSAGE
    lsl r16 ; r16 := r16*2 : for offset in ALPHABET

    ; find code of this letter in alphabet
    ldi r26, low (ALPHABET)
    add r26, r16 ; find offset of letter in ALPHABET
    ldi r27, high(ALPHABET)

    ; load litera from ALPHABET
    ld r20, X ; load litera length

    inc r26
    ld r21, X ; load litera code

    clr r19 ; clear counter of push operations

    LOAD_LITERA_LOOP:
    ; if litera length = 0 jump to finish
    clr r16
    cp r20, r16
    breq FINISH_LOAD_LITERA

    clr r17
    push r17 ; save 1 pause
    inc r19
    
    ; save '.' 
    ldi r17, 1
    push r17 ; save to CURRENT_LITERA_CODE to stack (for invert bits)
    inc r19
    
    SBRS r21, 0; Skip if Bit in Register Cleared => if r21[0] = 0 then jump and save '.' else not jump save '...' = '_'
    rjmp LOAD_LITERA_LOOP_END

    ; save aditional '..' to make '...' = '_'
    push r17
    inc r19
    push r17
    inc r19


    LOAD_LITERA_LOOP_END:
    dec r20 ; loop counter
    lsr r21 ; shift litera code to get next bit
    rjmp LOAD_LITERA_LOOP


    FINISH_LOAD_LITERA:

    ; set r26:27 to start of CURRENT_LITERA_CODE array
    ldi r27, high(CURRENT_LITERA_CODE) ; X = R27:R26
    ldi r26, low(CURRENT_LITERA_CODE)

    ; if push counter = 0, goto finish
    clr r16
    cp r19, r16
    breq FINISH_LOAD_LITERA_POP_LOOP

    LOAD_LITERA_POP_LOOP:
    pop r17
    st X, r17
    inc r26
    dec r19
    brne LOAD_LITERA_POP_LOOP ; if r19 (lenght of litera) /=0 then loop again

    FINISH_LOAD_LITERA_POP_LOOP:

    ser r17
    st X, r17 ; set to end of CURRENT_LITERA_CODE value 0xff

    pop r16
    out SREG, r16
    pop r21
    pop r20
    pop r19
    pop r17
    pop r16
    reti



INIT_MESSAGE:
    ldi r16, 9

    ldi r27, high(MESSAGE) ; X = R27:R26
    ldi r26, low(MESSAGE)
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    dec r16
    st X, r16

    inc r26
    ldi r16, 0xff
    st X, r16

    reti


INIT_ALPHABET:
    ldi r27, high(ALPHABET) ; X = R27:R26
    ldi r26, low(ALPHABET)

    ; 0
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00011111
    st X,r16
    inc r26

    ; 1
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00001111
    st X,r16
    inc r26

    ; 2
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00000111
    st X,r16
    inc r26

    ; 3
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00000011
    st X,r16
    inc r26

    ; 4
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00000001
    st X,r16
    inc r26

    ; 5
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00000000
    st X,r16
    inc r26

    ; 6
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00010000
    st X,r16
    inc r26

    ; 7
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00011000
    st X,r16
    inc r26

    ; 8
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00011100
    st X,r16
    inc r26

    ; 9
    ldi r16, 5
    st X,r16
    inc r26
    ldi r16, 0b00011110
    st X,r16
    inc r26

    reti






;---- EEPROM Segment
.eseg
