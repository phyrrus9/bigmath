addtest: src/addtest.c libbig.a
	gcc -O2 -g -o addtest src/addtest.c libbig.a
libbig.a: obj/bigarithmatic.o obj/bigcommon.o
	ar rcs libbig.a obj/bigarithmatic.o obj/bigcommon.o
obj/bigarithmatic.o: obj asm/bigadd.asm asm/bigsub.asm asm/bigarithmatic.asm asm/bigtostr.asm
	nasm -f elf64 -g -o obj/bigarithmatic.o asm/bigarithmatic.asm -F dwarf
obj/bigcommon.o: obj asm/bigcommon.asm
	nasm -f elf64 -g -o obj/bigcommon.o asm/bigcommon.asm -F dwarf
obj:
	mkdir -p obj
clean:
	rm -f addtest libbig.a
	rm -f obj/*
	rmdir obj
