;counter.asm
;  an 8-bit binary counter triggered by pin D2

.include "./m328Pdef.inc"

.def temp = r16
.def port_mask = r17
.def counter = r18

.org 0x00
    rjmp Setup

.org INT0addr
    rjmp ExternalInterrupt

Setup:
    ldi temp, (1 << INT0) ; enable external interrupt INT0
    out EIMSK, temp

    ldi temp, (1 << ISC01) | (1 << ISC00) ; Use rising edge of INT0
    sts EICRA, temp

    ldi port_mask, 0b11111111       ; set all PortB to output
    out DDRB, port_mask

    ldi temp, (1 << PORTD2) ; Enable pull-up on PortD2
    out PortD, temp

    sei

Start:
    rjmp Start

ExternalInterrupt:
    inc counter
    out PortB, counter

    reti
