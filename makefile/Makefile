# This is a demo to study Makefile
#
# by Yitao
# 1029-12-2
# make -w //special & usful command option 
#

TARGET = main
OBJECTS = test.o main.o
HEADERS = test.h

GCC = g++
.phony : all clean

LOG = ------$(GCC)---$2----$1------

all : $(TARGET)
	@echo "---done---"
	echo $(call LOG,hello,world)

$(TARGET) : $(OBJECTS)
	$(GCC) -o $@ $+
	@echo "$(TARGET) generated successfully"


%.o : %.cpp %.h
	$(GCC) -c -o $@ $<

# target variables
$(OBJECTS) :: CFLAGS=-g
$(OBJECTS) :: %.o : %.cpp
	$(GCC) -c $(CFLAGS) -o $@ $<
ifdef DEBUG
	@echo from static patten
endif

# double colon rule, multiple rules for the same target
# for the same target, either double colon or colon, mixed not permitted.
test.o :: test.h
ifdef DEBUG
	@echo from double colon rule
endif

# no recipe specifiled, only specify the dependency
#test.o : test.h

clean : 
	@echo "cleaned..."
	rm -rf *.o
	rm -rf main

