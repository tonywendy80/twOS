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

VIDEO_INDEX_REG = 0x3d4
VIDEO_DATA_REG  = 0x3d5

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

    call _get_cursor
    movw %ax, __pos

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

    pushw $0
    call _set_cursor
    addw $2, %sp

    popw %di
    movw %bp, %sp
    popw %bp
    ret
.size _clear_screen, .-_clear_screen

###################################
## Function : _printf
## INPUT    : (char* str)
## Return   : int -- the length of str which is printed
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

###################################
## Function : _put_char
## INPUT    : (char c)
## Return   : none
.type _put_char, @function
_put_char:
    pushw %bp
    movw %sp, %bp
    pushw %di

    movw 4(%bp), %ax

_put_0a:
    cmpb $0x0a, %al
    jnz _put_0d
    movw $80, %dx
    jmp _put_end
_put_0d:
    cmpb $0x0d, %al
    jnz _put_other
    movw __pos, %ax
    movb $80, %dl 
    div %dl 
    mul %dl 
    movw __pos, %dx
    subw %ax, %dx
    neg %dx
    jmp _put_end
_put_other:
    movw __pos, %di
    shl %di
    movw %ax, %es:(%di)
    movw $1, %dx

_put_end:
    pushw %dx ## %dx = cursor steps
    call _move_cursor
    addw $2, %sp

    popw %di
    movw %bp, %sp
    popw %bp
    ret
.size _put_char, . - _put_char

###################################
## Function : _move_cursor
## INPUT    : (short cursor_steps) positive:forward; negtive:backword;
## Return   : none
.type _move_cursor, @function
_move_cursor:
    pushw %bp
    movw %sp, %bp

    movw 4(%bp), %ax
    addl __pos, %ax
    pushw %ax
    call _set_cursor
    addw $2, %sp

    movw %bp, %sp
    popw %bp
    ret
.size _move_cursor, . - _move_cursor

###################################
## Function : _get_cursor
## INPUT    : none
## Return   : unsigned short - the position of current cursor
.type _get_cursor, @function
_get_cursor:
    pushw %bp
    movw %sp, %bp
    
    movw $VIDEO_INDEX_REG, %dx
    movb $0x0e, %al
    outb %al, %dx
    movw $VIDEO_DATA_REG, %dx
    inb %dx, %al
    movb %al, %ah

    movw $VIDEO_INDEX_REG, %dx
    movb $0x0f, %al
    outb %al, %dx
    movw $VIDEO_DATA_REG, %dx
    inb %dx, %al

    movw %bp, %sp
    popw %bp
    ret
.size _get_cursor, . - _get_cursor

###################################
## Function : _set_cursor
## INPUT    : (unsigned short pos)
## Return   : none
.type _set_cursor, @function
_set_cursor:
    pushw %bp
    movw %sp, %bp
    
    movw 4(%bp), %cx
    movw %cx, __pos

    movw $VIDEO_INDEX_REG, %dx
    movb $0x0e, %al
    outb %al, %dx
    movw $VIDEO_DATA_REG, %dx
    movb %ch, %al
    outb %al, %dx

    movw $VIDEO_INDEX_REG, %dx
    movb $0x0f, %al
    outb %al, %dx
    movw $VIDEO_DATA_REG, %dx
    movb %cl, %al
    outb %al, %dx

    movw %bp, %sp
    popw %bp
    ret
.size _set_cursor, . - _set_cursor

.section .data
__welcome_msg:
.ascii "Hello, MyOS!\n\rGreat! You can see the message!!!\n\r"
.ascii "Hello world! \r----"
.byte 0

__pos:
.word 0

.section .bss
