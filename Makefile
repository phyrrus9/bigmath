addtest: addtest.c bigadd.o
	gcc -o addtest addtest.c bigadd.o
bigadd.o: bigadd.asm
	nasm -f elf64 -o bigadd.o bigadd.asm
clean:
	rm -f addtest bigadd.o
