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
VIDEO_SEG = 0xb800
TEST_SEG  = 0xFFF0

## in Protected-mode
CODE_SEG = 0x08
DATA_SEG = 0x10
VIDEO2_SEG = 0x18
STACK_SEG = 0x20

.globl _start
.section .text
_start:
    .code16gcc
    ljmp $BOOT_SEG, $_go
_go:
    # Error: Attention!!!
    # Can't mov data dirrectly to %cs
    # movw %ax, %cs

    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %ss
    movw $__stack, %sp

    call _clear_screen

    movw %ds, %ax
    movw %ax, %es

    pushw $0x0101
    pushw $__welcome_msg
    call _printf16
    addw $4, %sp

    
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
    movw $VIDEO2_SEG, %ax
    movw %ax, %es
    lss __stack, %esp

    movl $STACK_SEG, %ebx
    lsl %ebx, %eax

    #pushl $0x12345678

_die:
    jmp _die

.code16gcc
###################################
## No Input Params
## Returns : None
.type _clear_screen, @function
_clear_screen:
    pushw %bp
    movw %sp, %bp
    movw $VIDEO_SEG, %ax
    movw %ax, %es
    mov $SCREEN_CHARS, %cx
    xor %ax, %ax
    rep stosw
    movw %bp, %sp
    popw %bp
    ret
.size _clear_screen, .-_clear_screen

###################################
## INPUT Params : (char* str, unsigned short pos) -- pos = X*Y
## Return       : int -- the length of str which is printed
.type _printf16, @function
_printf16:
    pushw %bp
    movw %sp, %bp

    movw 4(%bp), %si

    pushw %si
    call _strlen16
    addw $2, %sp

    movw %ax, %cx
    ## AL[bit0] - 0=don't move cursor, 1=move cursor
    ## AL[bit1] - 0=BL has attributes, 1=string has attributes
    movw $0x1301, %ax
    movw $ATTR_CHAR, %bx  ## char attribute in %bl

    pushw %bp
    movw %si, %bp
    int $0x10
    popw %bp

    movw %bp, %sp
    popw %bp
    ret 
.size _printf16,.-_printf16

###################################
## INPUT Params : (char* str)
## Return       : int - the length of str
.type _strlen16,@function
_strlen16:
    pushw %bp
    movw %sp, %bp
    pushw %si
    movw -4(%bp), %si
    movw %si, %ax
    movw  $0xff, %cx
    repnz scasb
    subw %ax, %si
    movw %si, %ax
    popw %si
    movw %bp, %sp
    popw %bp
    ret
.size _strlen16,.-_strlen16


.section .data
__welcome_msg:
.asciz "Hello, MyOS!"

.space 64
__stack:
.long 0xFFFFF
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
.long 0x7c00FFFF, 0x00C19200 # DS
.long 0x80007FFF, 0x0040920B # ES - VIDEO
.long 0x0000FFFF, 0x00C19640 # SS

.section .bss
