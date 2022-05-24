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
    # Error: Attention!!!
    # Can't mov data dirrectly to %cs
    # movw %ax, %cs

    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %ss
    movw $0, %sp

    call _clear_screen

    movw %ds, %ax
    movw %ax, %es

    pushw $0x0515 ## Cursor Location : Row-5, Column-21
    pushw $__welcome_msg
    call _printf16
    addw $4, %sp

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
    movw $VIDEO2_SEG, %ax
    movw %ax, %es

    ## LIMIT Checking
    ## Attention to the Setting in DS segment 
    ## You could set the LIMIT field to 0, and then check the follow two instructions' execution
    #movb (0), %bl
    #movb (1), %bh

    lss __stack, %esp

    ## Retrieving the segment limit
    movl $STACK_SEG, %ebx
    lsl %ebx, %eax

    pushl $0x12345678

    
    #################################
    ## enable interrupt before entering the main body
    sti

_die:
    jmp _die

.code16
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
    movw $0x0200, %ax
    xor %di, %di
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

    movw 4(%bp), %di

    pushw %di
    call _strlen16
    addw $2, %sp

    movw 6(%bp), %dx  ## DH:DL=Row:Column
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
.size _printf16,.-_printf16

###################################
## INPUT Params : (char* str)
## Return       : int - the length of str
.type _strlen16,@function
_strlen16:
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
.size _strlen16,.-_strlen16


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
