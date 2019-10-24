;blink.asm
;  blink an LED which is connected to PB5 (digital out 13)

.include "./m328Pdef.inc"

.def temp = r16
.def port_mask = r17
.def led_status = r18

Setup:
    ldi temp, (1 << CS12)           ; set the prescaler to 1/256
    sts TCCR1B, temp

    ldi temp, (1 << TOIE1)          ; set the Timer Overflow Interrupt Enable (TOIE1) bit
    sts TIMSK1, temp                ; of the Timer Interrupt Mask Register (TIMSK1)

    ldi port_mask, (1 << PORTB5)    ; set PB5 to output
    out DDRB, port_mask

    sei                             ; enable global interrupts

Start:
    rjmp Start

.org OVF1addr
TimerOverflow:
    eor led_status, port_mask
    out PortB, led_status

    reti