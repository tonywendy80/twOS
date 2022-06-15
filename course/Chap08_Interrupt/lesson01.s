
################################
## Author : tonyma
## Date   : 2022-06-10
## Email  : tonywendy80@qq.com
##
## File   : lesson01.s
## All rights reserved by tonywendy80
##############################################

SYSTEM_VMA = 0x9000

## Protected-mode
NULL_CORE_SEG  = 0x00
CODE_CORE_SEG  = 0x08
DATA_CORE_SEG  = 0x10
STACK_CORE_SEG = 0x18
VIDEO_CORE_SEG = 0x20
DATA_4G_SEG    = 0x28

LDT0_SEG = 0x30
TSS0_SEG = 0x38

CODE_SEG  = 0x40
CALL_GATE = 0x48

NULL_USER_SEG = 0x07
CODE_USER_SEG = 0x0f
DATA_USER_SEG = 0x17
STACK_USER_SEG = 0x1f

IDT_ENTRY_NUM = 0x30

EOI = 0x20

SECOND_POS = 15*160+15*2

.globl _start32
.section .text

    .code32
_start32:
    ##############################
    # init GDT again
    lgdt __gdt48
    ljmp $CODE_CORE_SEG, $_go32

_go32:
    movw $DATA_CORE_SEG, %ax
    movw %ax, %ds
    movw $VIDEO_CORE_SEG, %ax
    movw %ax, %es

    lss __core_stack, %esp


    ##############################
    # load TSS to task register
    movw $TSS0_SEG, %ax
    ltr %ax

    ##############################
    # load LDT to LDT register
    movw $LDT0_SEG, %ax
    lldt %ax

    ##############################
    # init IDT
    movl $IDT_ENTRY_NUM, %ecx
    movw $CODE_CORE_SEG, %ax
    shl $16, %eax
    leal _intr_handler, %edx
    movw %dx, %ax
    movw $0x8e00, %dx
    leal __idt, %edi
_next_idt_entry:
    movl %eax, %es:(%edi)
    movl %edx, %es:4(%edi)
    addl $8, %edi
    loop _next_idt_entry

    # RTC
    movl $__idt+8*0x28, %edi
    leal _rtc_handler, %edx
    movw %dx, %ax
    movw $0x8e00, %dx
    movl %eax, %es:(%edi)
    movl %edx, %es:4(%edi)

    # load idtr
    lidt __idt48
    

    ##############################
    # init 8259A
    # ICW1-4
    movb $0x11, %al
    outb %al, $0x20
    .word 0x00eb, 0x00eb
    outb %al, $0xA0
    .word 0x00eb, 0x00eb

    movb $0x20, %al
    outb %al, $0x21
    .word 0x00eb, 0x00eb
    movb $0x28, %al
    outb %al, $0xA1
    .word 0x00eb, 0x00eb

    movb $0x04, %al
    outb %al, $0x21
    .word 0x00eb, 0x00eb
    movb $0x02, %al
    outb %al, $0xA1
    .word 0x00eb, 0x00eb

    movb $0x01, %al
    outb %al, $0x21
    .word 0x00eb, 0x00eb
    outb %al, $0xA1
    .word 0x00eb, 0x00eb

    movb $0x00, %al
    outb %al, $0x21
    .word 0x00eb, 0x00eb
    outb %al, $0xA1
    .word 0x00eb, 0x00eb


    ##############################
    # RTC
    movb $0x8b, %al
    outb %al, $0x70
    movb $0x12, %al
    outb %al, $0x71

    sti

_die:
    jmp _die

_intr_handler:
    iret

_trap_handler:
    iret

_rtc_handler:
    movb $0x80, %al
    outb %al, $0x70
    inb $0x71, %al

    movb %al, %bl
    andb $0x0f, %bl
    addb $0x30, %bl
    movb $0x02, %bh
    
    movb %al, %dl
    andb $0xf0, %dl
    shr $4, %dl
    addb $0x30, %dl
    movb $0x02, %dh

    movw $VIDEO_CORE_SEG, %ax
    movw %ax, %es
    movw %dx, %es:(SECOND_POS)
    movw %bx, %es:(SECOND_POS+2)

    movb $0x0c, %al
    outb %al, $0x70
    inb $0x71, %al

    movb $EOI, %al
    outb %al, $0xa0
    outb %al, $0x20
    iret


.section .data
.align 8
__core_stack:
.long 0x0000
.word STACK_CORE_SEG

__user_stack:
.long 0x0000
.word STACK_USER_SEG



###################################
## GDT
.align 8
__gdt:
.long 0,0 # NULL

.long 0x9000FFFF, 0x00409a00 # CS 32bits
.long 0x9000FFFF, 0x00409200 # DS 32bits
.long 0x9000FFFF, 0x00409600 # SS 32bits - ExpandDown 0x200000
.long 0x80007FFF, 0x0040920B # ES 32bits - Video

.long 0x0000ffff, 0x008f9200 # DS 0-4G RW

.word 4*8-1, __ldt0+SYSTEM_VMA, 0xe200, 0x0000 # LDT0
.word 0x67, __tss0+SYSTEM_VMA, 0xe900, 0x0000 # TSS0
.long 0x9000FFFF, 0x00409e00 # Code Segment - Conforming
.word _die, CODE_CORE_SEG, 0x8c00, 0x0 # Call Gate

__gdt48:
## LIMIT is the total len minus 1 
.word .-__gdt-1
## THIS is VERY IMPORTANT that we have to specify the 'absolute physical address' for GDT
.long __gdt + SYSTEM_VMA

__ldt0:
.long 0,0 # NULL
.long 0x9000FFFF, 0x004FFA00 #Code User mode
.long 0x9000FFFF, 0x0040F200 #Data User mode
.long 0x0000FFFF, 0x0040F620 #Stack User mode, ExpandDown

__idt:
.fill IDT_ENTRY_NUM, 8, 0
__idt48:
    .word . - __idt - 1
    .long __idt + SYSTEM_VMA

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
.long    LDT0_SEG
.long    0x0000000


.section .bss
