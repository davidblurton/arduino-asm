.include "./m328Pdef.inc"

.DEF A = R16                 ;GENERAL PURPOSE ACCUMULATOR

.ORG 0000
ON_RESET:
    ldi A, 0b00100000       ;Set PB5 to output
	out DDRB, A
    LDI A, 0b00000101       ;SET TIMER PRESCALER TO /1024
    OUT TCCR0B, A

MAIN_LOOP:
    SBI PortB,0              ;FLIP THE 0 BIT
    RCALL PAUSE             ;WAIT
    RJMP MAIN_LOOP          ;GO BACK AND DO IT AGAIN

PAUSE:
PLUPE:
    IN A,TIFR0            ;WAIT FOR TIMER
    ANDI A,0b00000010    ;(1<<TOV0)
    BREQ PLUPE
    LDI A,0b00000010     ;RESET FLAG
    OUT TIFR0,A          ;NOTE: WRITE A 1 (NOT ZERO)
    RET