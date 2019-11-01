;counter.asm
;  an 8-bit binary counter

.include "./m328Pdef.inc"

.def temp = r16
.def counter = r18

Setup:
    ldi temp, (1 << CS11)           ; set the prescaler to 1/8
    sts TCCR1B, temp

    ldi temp, (1 << TOIE1)          ; set the Timer Overflow Interrupt Enable (TOIE1) bit
    sts TIMSK1, temp                ; of the Timer Interrupt Mask Register (TIMSK1)

    ldi temp, 0b11111111       ; set all PortB to output
    out DDRB, temp

    sei

Start:
    rjmp Start

.org OVF1addr
TimerOverflow:
    inc counter
    out PortB, counter

    reti