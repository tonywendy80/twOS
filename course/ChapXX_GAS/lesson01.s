################################
## Author : tonyma
## Date   : 2022-05-20 Love Day
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

BOOT_SEG  = 0x07c0
VIDEO_SEG = 0xb800

.globl _start
.text
_start:
    .code16gcc
    ljmp $BOOT_SEG, $_go
_go:
    # Error:
    # Can't mov data dirrectly to %cs
    # movw %ax, %cs

    movw %cs, %ax
    movw %ax, %ds
    seg ds
    movw __BOOT_FLAG, %ax

.data
__BOOT_FLAG:
.WORD 0xAA55

.bss
