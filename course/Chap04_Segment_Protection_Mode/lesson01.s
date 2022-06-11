################################
## Author : tonyma
## Date   : 2022-05-20 Love Day
## Email  : tonywendy80@qq.com
##
## File   : lesson01.s
## All rights reserved by tonywendy80
##############################################

SCREEN_CHARS = 2000
ATTR_CHAR = 0x02

## in Real-mode
BOOT_SEG  = 0x07c0

## in Protected-mode
CODE_SEG = 0x08
DATA_SEG = 0x10
VIDEO_SEG = 0x18
STACK_SEG = 0x20

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
    movw %ax, %ss
    movw $0, %sp


    ##########################
    ## Before changing the system setting, disable interrupt from outsides
    cli

    ##########################
    ## Setup GLDT
    lgdt __gdt_48

    ##########################
    ## Enter Protected Mode
    smsw %ax
    orw $0x01, %ax
    lmsw %ax

    ##########################
    ## Initial CS/DS/ES
    ljmp $CODE_SEG, $_start32

    .code32
_start32:
    movw $DATA_SEG, %ax
    movw %ax, %ds
    movw $VIDEO_SEG, %ax
    movw %ax, %es

    ## LIMIT Checking
    ## Attention to the Setting in DS segment 
    ## You could set the LIMIT field to 0, and then check the follow two instructions' execution
    #movb (0), %bl
    #movb (1), %bh

    ## load data into %ss:%esp
    lss __stack, %esp

    ## Retrieving the segment limit
    movl $STACK_SEG, %ebx
    lsl %ebx, %eax

    ## Operation on stack
    pushl $0x12345678
    popl %eax

    #################################
    ## enable interrupt before entering the main body
    sti

    #################################
    ## BODY

_die:
    jmp _die


.section .data
__welcome_msg:
.asciz "Hello, MyOS!\r\n"


__stack:
.long 0
.word STACK_SEG

.align 8
.word 0
__gdt_48:
## LIMIT is the total len minus 1 
.word 5*8-1
## THIS is VERY IMPORTANT that we have to specify the 'absolute physical address' for GDT
.long __gdt + (BOOT_SEG<<4)

###################################
## 0x08 - Code 
## 0x10 - Data
## 0x18 - VIDEO
## 0x20 - STACK
__gdt:
.long 0,0
.long 0x7c00FFFF, 0x004F9A00 # CS
.long 0x7c00FFFF, 0x00409200 # DS
.long 0x80007FFF, 0x0040920B # ES - VIDEO
.long 0x0000FFFF, 0x00019240 # SS

.section .bss
