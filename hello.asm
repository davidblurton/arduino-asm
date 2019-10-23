;hello.asm
;  turns on an LED which is connected to PB5 (digital out 13)

.include "./m328Pdef.inc"

.def overflows = r17

.ORG 0000
Setup:
	ldi r16, 0b00100000
	out DDRB, r16           ;Set PB5 to output

    ldi r16, (1<<COM0A0)|(1<<WGM01)   ; CTC mode
    out TCCR0A, r16

    ldi r16, (5<<CS00)      ;Set timer prescaler to 1024
    out TCCR0B, r16

    ldi r16, 255            ;Set overflow to 255
    out OCR0A, r16

    clr overflows

Start:
    rcall Pause
	rjmp Start

Pause:
    in r16, TIFR0            ;read the Timer Interrupt Flag Register
    sbrs r16, OCF0A          ;test the overflow flag
    ret                      ;return if not set

    ldi r16, 0b00000010      ;reset timer
    out TIFR0, r16

    inc overflows
    cpi overflows, 61
    brne Start                ;skip next line if equal

    clr overflows

    ; Toggle the LED
    ldi r16, 0b00100000
    in r24, PortB
    eor r24, r16
    out PortB, r24

    ret
