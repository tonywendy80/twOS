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
    .code16
    ljmp $BOOT_SEG, $_go
_go:
    # Error: Attention!!!
    # Can't mov data dirrectly to %cs
    # movw %ax, %cs

    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0, %sp

    call _clear_screen

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

    pushl $0x15
    pushl $0x5
    pushl $__welcome_msg
    call _printf
    addl $12, %esp
    
_die:
    jmp _die


###################################
## INPUT Params : (char* str, unsigned char row, unsinged char col)
## Return       : int -- the length of str which is printed
.type _printf, @function
_printf:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %edi

    # Calc the string len
    movl 8(%ebp), %esi
    pushl %esi
    call _strlen
    addl $4, %esp
    movl %eax, %ecx

    # Calc the dest/video-mem addr based on position(x,y)
    mov 0x0c(%ebp), %eax
    movl $160, %edx
    mulb %dl
    movl 0x10(%ebp), %edx
    shl $1, %edx
    addl %edx, %eax
    movl %eax, %edi

_printf_loop:
    movb %ds:(%esi), %al
    movl $0x160, %edx
    cmpb $0x0a, %al # '\n'
    jz _printf_stepforward
    cmpb $0x0d, %al # '\r'
    jz _printf_stepforward
    movl $0x02, %edx
_printf_out:
    movb %al, %es:(%edi)
_printf_stepforward:
    inc %esi
    addl %edx, %edi
    loop _printf_loop

    popl %edi
    popl %esi
    movl %ebp, %esp
    popl %ebp
    ret 
.size _printf,.-_printf

###################################
## INPUT Params : (char* str)
## Return       : int - the length of str
.type _strlen,@function
_strlen:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    movl 8(%ebp), %edi
    movl  $0xff, %ecx
_strlen_loop:
    inc %edi
    cmpb $0, -1(%edi)
    loopnz _strlen_loop
    subl 8(%ebp), %edi
    movl %edi, %eax
    dec %eax
    popl %edi
    movl %ebp, %esp
    popl %ebp
    ret
.size _strlen,.-_strlen


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


.section .data
__welcome_msg:
.asciz "Hello, MyOS!\r\n"

__stack:
.long 0x10000
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
.long 0x0000FFFF, 0x00409240 # SS

.section .bss