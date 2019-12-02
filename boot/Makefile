# Makefile for boot.img
# by myt
# 2019-12-02

TARGET = /build/i323251/Yitao

.PHONY : all clean

all : boot.img
	cp $< ${TARGET}
	@echo "<boot.img> copied to target!"
	
boot.img : bootsect
	dd bs=32 skip=1 if=$< of=$@
	@echo "<boot.img> generated successfully!"

bootsect : bootsect.o
	ld86 -0 -s -o $@ $<

%.o : %.S
	as86 -0 -a -o $@ $<

clean :
	rm -f *.o
	rm -f bootsect
	rm -f boot.img

