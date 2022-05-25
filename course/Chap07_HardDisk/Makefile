################################
## Author : tonyma
## Date   : 2022-05-25
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

ASFLAGS = --32
LDFLAGS = -m elf_i386 -T lesson.lds

SRCS = readsect.s
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
