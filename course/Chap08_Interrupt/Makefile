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

.PHONY : all clean

all  : $(BINS)
	@echo "  -- $(EXES)  --"
	@echo "  (: all done! :)"

$(BINS) : %.bin : %
	objcopy -O binary $< $@

$(EXES) : % : %.o $(BOOT_OBJ)
	ld $(LDFLAGS) -o $@ $^

$(OBJECTS) : %.o  : %.s
	as $(ASFLAGS) -o $@ $<

$(BOOT_OBJ) : $(BOOT_SRC)
	as $(ASFLAGS) -o $@ $<

clean :
	rm -rf $(OBJECTS) $(EXES) $(BINS) $(BOOT_OBJ)
