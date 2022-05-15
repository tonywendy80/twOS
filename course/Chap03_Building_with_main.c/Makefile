### Makefile
### Author : tonyma
### Date   : 2022-5-14
### email  : tonywendy80@qq.com
#########################################

ASFLAGS = --32
CFLAGS = -m32 -c -nostdlib -nostdinc -fno-exceptions -fno-builtin
LDFLAGS = -m elf_i386


.PHONY : all clean

all : boot.bin mixed.bin
	@echo "all done!"

boot.bin : boot
	objcopy -O binary $< $@
	@echo "$@ generated successfully!"

boot : boot.o
boot : boot.lds
	ld $(LDFLAGS) -o $@ -T $^

boot.o : boot.s
	as $(ASFLAGS) -o $@ $<

###################################

mixed.bin : mixed
	objcopy -O binary $< $@
	@echo "$@ generated successfully!"

mixed : mixed.lds boot_2m.o main.o
	ld $(LDFLAGS) -o $@ -T $^

boot_2m.o : boot_2m.s
	as $(ASFLAGS) -o $@ $<

main.o : main.c
	gcc $(CFLAGS) -o $@ $< 


clean : 
	rm -f boot.o boot boot.bin 
	rm -f boot_2m.o main.o mixed mixed.bin

