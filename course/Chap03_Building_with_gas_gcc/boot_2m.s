
# GNU as Grammar
# Author: tonyma
# Date: 2022-5-14
# File: boot_2m.s
####################################

VIDEO_SEG = 0xb800
BOOT_SEG = 0x07c0
SCREEN_SIZE = 2000
ATTR_CHAR = 0x0200

.section .data

.section .bss

.section .text
.globl _start, clear_screen, main
_start:
    .code16gcc  ## This pseudo-op will generate 16bits object.
    ljmp $BOOT_SEG, $_go
_go: 
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %ss
    movw $_stack, %ax
    movw %ax, %sp

    pushl $0
    pushl $0
    call main

_die:
    jmp _die

#######################################
# Function : clean the whole screen
clear_screen:
.type clear_screen, @function
    pushl %ebp
    movl %esp, %ebp

    movw $VIDEO_SEG, %ax
    movw %ax, %es
    xor %di, %di
    movw $ATTR_CHAR, %ax
    movw $SCREEN_SIZE, %cx
    cld
    rep stosw

    movl %ebp, %esp
    popl %ebp
    retl
.size clear_screen,.-clear_screen

