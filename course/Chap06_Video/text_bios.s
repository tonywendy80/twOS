################################
## Author : tonyma
## Date   : 2022-05-24 Love Day
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
    movw %ax, %es

    cld
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
    pushw %es
    movw $VIDEO_SEG, %ax
    movw %ax, %es
    
    mov $SCREEN_CHARS_NUM, %cx
    movw $0x0200, %ax
    xor %di, %di
    rep stosw

    popw %es
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

    movw 4(%bp), %di

    pushw %di
    call _strlen
    addw $2, %sp

    movw $0x0000, %dx  ## DH:DL=Row:Column
    movw %ax, %cx
    ## AL[bit0] - 0=don't move cursor, 1=move cursor
    ## AL[bit1] - 0=BL has attributes, 1=string has attributes
    movw $0x1301, %ax
    movw $ATTR_CHAR, %bx  ## char attribute in %bl

    pushw %bp
    movw %di, %bp
    int $0x10
    popw %bp

    movw %bp, %sp
    popw %bp
    ret 
.size _printf, .-_printf

###################################
## INPUT  : (char* str)
## Return : int - the length of str
.type _strlen,@function
_strlen:
    pushw %bp
    movw %sp, %bp
    pushw %di
    
    movw 4(%bp), %di
    movw $0, %ax
    movw  $0xff, %cx
    repnz scasb
    subw 4(%bp), %di
    movw %di, %ax
    dec %ax

    popw %di
    movw %bp, %sp
    popw %bp
    ret
.size _strlen,.-_strlen


.section .data
__welcome_msg:
.asciz "Hello, MyOS!"


.section .bss
