################################
## Author : tonyma
## Date   : 2022-05-27
## Email  : tonywendy80@qq.com
##
## File   : lesson04.s
## All rights reserved by tonywendy80
##############################################


## in Real-mode
BOOT_SEG  = 0x07c0

## in Protected-mode
NULL_CORE_SEG  = 0x00
CODE_CORE_SEG  = 0x08
DATA_CORE_SEG  = 0x10
STACK_CORE_SEG = 0x18
VIDEO_CORE_SEG = 0x20

CODE_SEG = 0x28
CALL_GATE = 0x30

LDT_SEG = 0x38
TSS_SEG = 0x40

CODE_USER_SEG = 0x07
DATA_USER_SEG = 0x0f
STACK_USER_SEG = 0x17


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

    cli

    ##########################
    ## Setup GLDT
    lgdt __gdt48


    ##########################
    ## Enter Protected Mode
    smsw %ax
    orw $0x01, %ax
    lmsw %ax

    ##########################
    ## Goto 32bits Protected Mode
    ljmp $CODE_CORE_SEG, $_start32

    .code32
_start32:
    movw $DATA_CORE_SEG, %ax
    movw %ax, %ds
    movw $VIDEO_CORE_SEG, %ax
    movw %ax, %es

    lss __core_stack, %esp


    ##############################
    # TEST1: you could uncomment any of the following lines to validate the call gate
    #ljmp $CODE_SEG, $_die
    #ljmp $CALL_GATE, $_die


    ##############################
    # load TSS to task register
    movw $TSS_SEG, %ax
    ltr %ax

    ##############################
    # load LDT to LDT register
    movw $LDT_SEG, %ax
    lldt %ax


    ##############################
    # enter user mode
    # 1. make sure the NT flag is clear to avoid task switch
    # 2. push SS, ESP, EFLAGS, CS, IP -> stack, then iret
    pushfl
    andl $0xffffbfff, (%esp)
    popfl

    sti

    push $STACK_USER_SEG
    push $0
    pushfl
    pushl $CODE_USER_SEG
    pushl $_usermode
    iret


_usermode:
    movw $DATA_USER_SEG, %ax
    movw %ax, %ds

    lss __user_stack, %esp

    ##############################
    # TEST2: we can access the conforming code segment regardless its DPL
    movw $CODE_CORE_SEG, %ax
    movw %ax, %es
    movl %es:(0), %eax

    ##############################
    # TEST3: verity whether the user stack works perfectly
    pushl %eax


_die:
    jmp _die



.section .data

.align 8
__core_stack:
.long 0x0000
.word STACK_CORE_SEG

__user_stack:
.long 0x0000
.word STACK_USER_SEG


.align 8
###################################
## GDT
__gdt:
.long 0,0

.long 0x7c00FFFF, 0x004F9a00 # CS 32bits
.long 0x7c00FFFF, 0x00409200 # DS 32bits
.long 0x0000FFFF, 0x00409620 # SS32 - ExpandDown
.long 0x80007FFF, 0x0040920B # ES 32bits - Video

.long 0x7c00FFFF, 0x00409A00 # CS 32bits    
.word _die, CODE_SEG, 0x8c00, 0x0000 # Call Gate 32bits 

.word 0x001f, __ldt0+0x7c00, 0xe200, 0x0000  # LDT  
.word 0x0067, __tss0+0x7c00, 0xe900, 0x0000  # TSS  

__gdt48:
## LIMIT is the total len minus 1 
.word .-__gdt-1
## THIS is VERY IMPORTANT that we have to specify the 'absolute physical address' for GDT
.long __gdt + (BOOT_SEG<<4)

__ldt0:
.long 0x7c00FFFF, 0x004FFA00 #Code User mode
.long 0x7c00FFFF, 0x0040F200 #Data User mode
.long 0x0000FFFF, 0x0040F620 #Stack User mode, ExpandDown

__tss0:
.long    0
.long    0, STACK_CORE_SEG
.long    0, 0
.long    0, 0
.long    0
.long    _die
.long    0
.long    0, 0, 0, 0, 0, 0, 0, 0
.long    0, CODE_USER_SEG, STACK_USER_SEG, DATA_USER_SEG, 0, 0
.long    LDT_SEG
.long    0x0000000


.section .bss
