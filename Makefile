all:
	dasm ./src/*.asm -f3 -v0 -Isrc -ocart.bin

run:
	stella cart.bin
