;hello.asm
;  turns on an LED which is connected to PB5 (digital out 13)

.include "./m328Pdef.inc"

.ORG 0000
Setup:
	ldi r16, 0b00100000
	out DDRB, r16           ;Set PB5 to output
    out PortB, r16          ;Set PB5 to high

    ldi r16, (1<<COM0A0)|(1<<WGM01)   ; CTC mode
    out TCCR0A, r16

    ldi r16, (5<<CS00)      ;Set timer prescaler to 1024
    out TCCR0B, r16

    ldi r16, 255            ;Set overflow to 255
    out OCR0A, r16

Start:
    ldi r16, 0b00100000
    in r24, PortB
    eor r24, r16
    out PortB, r24

    rcall Pause
	rjmp Start

Pause:
Plupe:
    in r16, TIFR0            ;WAIT FOR TIMER
    ANDI r16, 0b00000010

    BREQ Plupe

    ldi r16, 0b00000010      ;RESET FLAG
    out TIFR0, r16           ;NOTE: WRITE A 1 (NOT ZERO)
    ret