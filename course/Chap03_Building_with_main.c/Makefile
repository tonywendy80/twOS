### Makefile
### Author : tonyma
### Date   : 2022-5-14
### email  : tonywendy80@qq.com
#########################################

ASFLAGS = --32
CFLAGS = -m32
LDFLAGS = -m elf_i386


.PHONY : all clean

all : boot.bin mixed.bin

boot.bin : boot
	objcopy -O binary $< $@
	@echo "all done!"

boot : boot.o
boot : boot.lds
	ld $(LDFLAGS) -o $@ -T $^

boot.o : boot.s
	as $(ASFLAGS) -o $@ $<

###################################

mixed.bin : mixed

mixed : boot_2m.o main.o

boot_2m.o : boot_2m.s


main.o : main.c



clean : 
	rm -f boot.o boot boot.bin 
	rm -f boot_2m.o main.o mixed mixed.bin

