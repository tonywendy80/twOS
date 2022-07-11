################################
## Author : tonyma
## Date   : 2022-05-26
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

ASFLAGS = --32
LDFLAGS = -m elf_i386 -T link.lds

BOOT_SRC = boot.s
BOOT_OBJ = boot.o
SRCS = basic.s lesson01.s
OBJECTS =  $(SRCS:%.s=%.o)
EXES =  $(SRCS:%.s=%)
BINS = $(SRCS:%.s=%.bin)
SYMS = $(SRCS:%.s=%.sym)
IMGS = $(SRCS:%.s=%.img)

.PHONY : all clean

all  : $(IMGS) $(SYMS)
	@echo "  -- $(EXES)  --"
	@echo "  (: all done! :)"

$(IMGS) : %.img : %.bin
	dd if=$< of=$@ bs=512
	# 9 = 1 boot sector + 8 system sectors(1 page)
	dd if=/dev/zero of=$@ bs=512 seek=9 count=331

$(BINS) : %.bin : %
	objcopy -O binary $< $@

$(SYMS) : %.sym : %
	nm $< | awk '{print $$1 " " $$3}' >$@

$(EXES) : % : %.o $(BOOT_OBJ)
	ld $(LDFLAGS) -o $@ $^

$(OBJECTS) : %.o  : %.s
	as $(ASFLAGS) -o $@ $<

$(BOOT_OBJ) : $(BOOT_SRC)
	as $(ASFLAGS) -o $@ $<

clean :
	rm -rf $(OBJECTS) $(EXES) $(BINS) $(BOOT_OBJ) $(SYMS)
