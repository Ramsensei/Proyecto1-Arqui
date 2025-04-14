
all:
	nasm -f elf32 Interpolador.asm -o interpolador.o
	ld -m elf_i386 interpolador.o -o interpolador_asm
	./interpolador_asm

run:
	./interpolador_asm

clean:
	rm -f interpolador.o
	rm -f interpolador_asm
	
build:
	nasm -f elf32 Interpolador.asm -o interpolador.o
	ld -m elf_i386 interpolador.o -o interpolador_asm