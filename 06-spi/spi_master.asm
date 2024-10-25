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

    ; Enable global interrupts
    sei


    
MAIN:
    ; write data into SPDR, to start SPI Transfer
    clr r30
    out SPDR, r30
    inc r30
    LOOP:
    rjmp LOOP


; Interrupt Service Routine for SPI Serial Transfer Complete
SPI_STC_ISR:
    in r31, SPDR
    out SPDR, r30
    inc r30
    reti


;---- EEPROM Segment
.eseg
