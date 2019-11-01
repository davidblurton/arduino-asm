all:
	avra counter2.asm

flash: all
	avrdude -p m328p -c stk500v1 -b 57600 -P /dev/cu.wchusbserial1420 -U flash:w:counter.hex

dump:
	avr-objdump -m avr5 -D counter2.hex

tone:
	avr-gcc -mmcu=atmega328p tone_loop_20.S -o tone.o
	avr-objcopy -O ihex tone.o tone.hex
	avrdude -p m328p -c stk500v1 -b 57600 -P /dev/cu.wchusbserial1420 -U flash:w:tone.hex