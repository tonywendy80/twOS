# Makefile

.PHONY : clean all

all : boot.bin 
	@echo "Done!!!"

boot.bin : boot
	dd if=$< of=$@ bs=32 skip=1

boot : boot.o
	ld86 -0 -s -o $@ $<

boot.o : bootsect.S
	as86 -0 -o $@ $<

clean : 
	rm -f boot.bin boot boot.o


