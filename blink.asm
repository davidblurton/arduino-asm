;blink.asm
;  blink an LED which is connected to PB5 (digital out 13)

.include "./m328Pdef.inc"

.def temp = r16
.def overflow_counter = r17
.def led_status = r18

.equ OVERFLOW_COUNT = 61        ; (16000000/1024)/(255*61) ~ 1Hz

.org 0000
rjmp Setup

.org 0x0020
rjmp TimerOverflow

Setup:
	ldi temp, (1 << PORTB5)
	out DDRB, temp              ; set PB5 to output

    ldi temp, (1 << CS00) | (1 << CS02)
    out TCCR0B, temp            ; set the Clock Selector Bits CS00, CS01, CS02 to 101
                                ; this puts Timer Counter0, TCNT0 in to FCPU/1024 mode
                                ; so it ticks at the CPU freq/1024
    ldi temp, (1 << TOIE0)
    sts TIMSK0, temp            ; set the Timer Overflow Interrupt Enable (TOIE0) bit
                                ; of the Timer Interrupt Mask Register (TIMSK0)

    sei                         ; enable global interrupts

Start:
	rjmp Start

TimerOverflow:
    inc overflow_counter
    cpi overflow_counter, OVERFLOW_COUNT
    brne return                 ; go to return if not equal

    clr overflow_counter

    ldi temp, (1 << PORTB5)     ; toggle the LED
    in led_status, PortB
    eor led_status, temp
    out PortB, led_status

return:
    reti