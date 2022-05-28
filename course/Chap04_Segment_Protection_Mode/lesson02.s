################################
## Author : tonyma
## Date   : 2022-05-20 Love Day
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

SCREEN_CHARS = 2000
ATTR_CHAR = 0x02

## in Real-mode
BOOT_SEG  = 0x07c0

## in Protected-mode
CODE16_SEG = 0x08
CODE32_SEG = 0x10
DATA_SEG = 0x18
VIDEO_SEG = 0x20
STACK16_SEG = 0x28  # 16bits
STACK32_SEG = 0x30  # 32bits

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
    movw %ax, %es

    ##############################
    ## stack ops in real-mode
    push $0xfab1
    pushw $0xfab2
    pushl $0xfab3
    movw $0xdeaf, %ax
    push %ax
    pushw %ax
    pushl %eax


    ##########################
    ## Setup GLDT
    lgdt __gdt_48

    ##########################
    ## Enter Protected Mode
    smsw %ax
    orw $0x01, %ax
    lmsw %ax

    ##########################
    ## Goto 32bits Protected Mode
    #ljmp $CODE32_SEG, $_start32

    ##########################
    ## Goto 16bits Protected Mode
    ljmp $CODE16_SEG, $_start16

    .code32
_start32:
    movw $DATA_SEG, %ax
    movw %ax, %ds
    movw $VIDEO_SEG, %ax
    movw %ax, %es

    lss __stack16, %esp
    ##############################
    ## 16bits stack ops in 32bits protected mode
    push $0xfab1
    pushw $0xfab2
    pushl $0xfab3
    movw $0xdeaf, %ax
    push %eax
    pushw %ax
    pushl %eax


    lss __stack32, %esp
    ##############################
    ## 32bits stack ops in 32bits protected mode
    push $0xfab1
    pushw $0xfab2
    pushl $0xfab3
    movw $0xdeaf, %ax
    push %eax
    pushw %ax
    pushl %eax

_die32:
    hlt
    jmp _die32
    
.code16
_start16:
    movw $DATA_SEG, %ax
    movw %ax, %ds

    lss __stack16, %esp
    ##############################
    ## 16bits stack ops in 16bits protected mode
    push $0xfab1
    pushw $0xfab2
    pushl $0xfab3
    movw $0xdeaf, %ax
    push %ax
    pushw %ax
    pushl %eax


    lss __stack32, %esp
    ##############################
    ## 32bits stack ops in 16bits protected mode
    push $0xfab1
    pushw $0xfab2
    pushl $0xfab3
    movw $0xdeaf, %ax
    push %ax
    pushw %ax
    pushl %eax


_die16:
    hlt
    jmp _die16



.section .data

.align 8
__stack16:
.long 0x0000
.word STACK16_SEG

.align 8
__stack32:
.long 0x0000
.word STACK32_SEG


.align 8
.word 0
__gdt_48:
## LIMIT is the total len minus 1 
.word 7*8-1
## THIS is VERY IMPORTANT that we have to specify the 'absolute physical address' for GDT
.long __gdt + (BOOT_SEG<<4)

###################################
## GDT
__gdt:
.long 0,0
.long 0x7c00FFFF, 0x000F9A00 # CS 16bits
.long 0x7c00FFFF, 0x004F9A00 # CS 32bits
.long 0x7c00FFFF, 0x00409200 # DS 32bits
.long 0x80007FFF, 0x0040920B # ES 32bits - Video
.long 0x00000000, 0x00009600 # SS16 - ExpandDown
.long 0x0000FFFF, 0x00409600 # SS32 - ExpandDown

.section .bss
