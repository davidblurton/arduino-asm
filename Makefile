all:
	avra hello.asm

flash:
	avrdude -p m328p -c stk500v1 -b 57600 -P /dev/cu.wchusbserial1410 -U flash:w:hello.hex