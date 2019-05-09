all: compil link start

compil:
	nasm -felf64  printf.asm
	gcc -no-pie -c main.c -o main.o

link:
	gcc -no-pie -o run printf.o main.o

start:
	./run s

test: compil link 
	./run t

debug: compil link
	gdb ./run

clean:
	rm printf.o run main.o
