################################
## Author : tonyma
## Date   : 2022-05-20 Love Day
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

ASFLAGS = --32
LDFLAGS = -m elf_i386 -T lesson.lds

SRCS = lesson01.s lesson02.s lesson03.s lesson04.s
OBJECTS =  $(SRCS:%.s=%.o)
EXES =  $(SRCS:%.s=%)
BINS = $(SRCS:%.s=%.bin)

.PHONY : all clean

all  : $(BINS)
	@echo "  -- $(EXES)  --"
	@echo "  (: all done! :)"

$(BINS) : %.bin : %
	objcopy -O binary $< $@

$(EXES) : % : %.o
	ld $(LDFLAGS) -o $@ $<

$(OBJECTS) : %.o  : %.s
	as $(ASFLAGS) -o $@ $<


clean :
	rm -rf $(OBJECTS) $(EXES) $(BINS)
