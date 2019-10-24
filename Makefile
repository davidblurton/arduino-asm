all:
	avra blink.asm
	# avr-as -mmcu=atmega328p blink.asm

flash: all
	avrdude -p m328p -c stk500v1 -b 57600 -P /dev/cu.wchusbserial1410 -U flash:w:blink.hex

dump:
	avr-objdump -m avr5 -D blink.hex