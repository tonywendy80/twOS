################################
## Author : tonyma
## Date   : 2022-05-24
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

SCREEN_CHARS_NUM = 2000
ATTR_CHAR        = 0x02

## in Real-mode
BOOT_SEG  = 0x07c0
VIDEO_SEG = 0xb800

.globl _start
.section .text
_start:
    .code16
    ljmp $BOOT_SEG, $_go
_go:
    movw %cs, %ax
    movw %ax, %ds

    movw $VIDEO_SEG, %ax
    movw %ax, %es

    call _clear_screen

    pushw $__welcome_msg
    call _printf
    addw $2, %sp


_die:
    jmp _die


###################################
## Input   : None
## Return  : None
.type _clear_screen, @function
_clear_screen:
    pushw %bp
    movw %sp, %bp
    pushw %di
    
    mov $SCREEN_CHARS_NUM, %cx
    movw $0x0200, %ax
    xor %di, %di
    rep stosw

    popw %di
    movw %bp, %sp
    popw %bp
    ret
.size _clear_screen, .-_clear_screen

###################################
## INPUT  : (char* str)
## Return : int -- the length of str which is printed
.type _printf, @function
_printf:
    pushw %bp
    movw %sp, %bp
    pushw %di

    movw 4(%bp), %di

_put_next_char:
    movb (%di), %al
    cmpb $0x00, %al
    jz _done_printf
    movb $ATTR_CHAR, %ah
    pushw %ax
    call _put_char
    addw $2, %sp
    inc %di
    jmp _put_next_char

_done_printf:
    popw %di
    movw %bp, %sp
    popw %bp
    ret 
.size _printf, .-_printf

.type _put_char, @function
_put_char:
    pushw %bp
    movw %sp, %bp
    pushw %di

    movw 4(%bp), %ax
    movw __mem_pos, %di
    movw %ax, %es:(%di)
    addw $2, %di
    movw %di, __mem_pos

    popw %di
    movw %bp, %sp
    popw %bp
    ret
.size _put_char, . - _put_char

.section .data
__welcome_msg:
.asciz "Hello, MyOS!"

__mem_pos:
.word 0x00

.section .bss
