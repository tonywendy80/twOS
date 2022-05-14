
# GNU as Grammar
# Author: tonyma
# Date: 2022-5-14
# File: boot.s
####################################

VIDEO_SEG = 0xb800
BOOT_SEG = 0x07c0
SCREEN_SIZE = 2000
ATTR_CHAR = 0x0200

.section .data

.section .bss


.section .text
.globl _start
_start:
    .code16gcc  ## This pseudo-op will generate 16bits object.
    ljmp $BOOT_SEG, $_go
_go: 
    movw %cs, %ax
    movw %ax, %ds
    movw $VIDEO_SEG, %ax
    movw %ax, %es

    # clean the whole screen
    xor %di, %di
    movw $ATTR_CHAR, %ax
    movw $SCREEN_SIZE, %cx
    cld
    rep stosw

    # print out 'Hello, My OS!' to the screen
    movw $MSG, %si
    xor %di, %di
    movw MSG_SIZE, %cx
_rpt:
    movb (%si), %al
    movb %al, %es:(%di)
    inc %si
    addw $2, %di
    loop _rpt

_die:
    jmp _die

MSG:
.asciz "Hello, My OS!"
MSG_SIZE:
.word . - MSG

.org 510
.word 0xAA55 # boot sector flag
