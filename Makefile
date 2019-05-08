all: compil link run

compil:
	nasm -felf64 printf.asm

link:
	ld printf.o -o printf
run:
	./printf

debug: compil link
	gdb ./printf

clean:
	rm printf printf.o