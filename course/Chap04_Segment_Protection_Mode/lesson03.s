################################
## Author : tonyma
## Date   : 2022-05-27
## Email  : tonywendy80@qq.com
##
## File   : lesson03.s
## All rights reserved by tonywendy80
##############################################


## in Real-mode
BOOT_SEG  = 0x07c0
VIDEO_SEG = 0xb800

A20_INIT_POS = 15*160+25*2 # (row15, col25)


.globl _start
.section .text
_start:
    .code16
    ljmp $BOOT_SEG, $_go
_go:
    # Error: Attention!!!
    # Can't mov data dirrectly to %cs
    # movw %ax, %cs

    movw %cs, %ax
    movw %ax, %ds

    movw $VIDEO_SEG, %ax
    movw %ax, %es
    movw $A20_INIT_POS, %di


    #################################
    ## check A20
    ## Port 0x92 -- Fast A20 Register in ICH
    inb $0x92, %al
    test $0x02, %al
    jz _A20_DISABLED
_A20_ENABLED:
    movw $0x0259, %es:(%di)   ## default after reset
    jmp _disable_A20
_A20_DISABLED:
    movw $0x024e, %es:(%di)

    #################################
    ## disable A20
_disable_A20:
    movb $0, %al
    outb %al, $0x92
    movw $0x024e, %es:(%di)


    #################################
    ## write data to address 0x100000
    ## to check whether it's unwind
    push %es
    mov $0xffff, %ax
    mov %ax, %es
    movw $0x1234, %ax
    movw %ax, %es:(0x10)

    ###
    # In bochs, use xp /2wx 0x0 to check 
    # whether it writes the data 0x1234 to address 0x00.
    ###


_die:
    hlt
    jmp _die


.section .data


.section .bss
