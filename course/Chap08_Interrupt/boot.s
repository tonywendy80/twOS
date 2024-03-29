##############################################
## Author : tonyma
## Date   : 2022-06-13
## Email  : tonywendy80@qq.com
## File   : boot.s
## All rights reserved by tonywendy80
##############################################

BOOT_SEG   = 0x07c0

SYSTEM_SEG = 0x9000
SYSTEM_NR_SECTORS = 8
SYSTEM_SECTOR1    = 1

CHAR_ATTR = 0x02   # GREEN

NULL_SEG  = 0x00
CODE_SEG  = 0x08
DATA_SEG  = 0x10
STACK_SEG = 0x18
VIDEO_SEG = 0x20
DATA_4G_SEG = 0x28


HD0_BASEPORT = 0x1f0
HD0_DATA_PORT = HD0_BASEPORT
HD0_COUNTER_PORT = HD0_BASEPORT + 2
HD0_ADDR1_PORT = HD0_BASEPORT + 3
HD0_ADDR2_PORT = HD0_BASEPORT + 4
HD0_ADDR3_PORT = HD0_BASEPORT + 5
HD0_DEVICE_PORT = HD0_BASEPORT + 6
HD0_CMD_PORT = HD0_BASEPORT + 7
HD0_STATUS_PORT = HD0_CMD_PORT

LBA28_DEVICE_MASTER = 0xe0 #HD0
LBA28_DEVICE_SLAVE  = 0xf0 #HD1

CMD_READ = 0x20
CMD_WRITE = 0x30

.globl _start

.code16
.section .text
_start:
    ljmp $BOOT_SEG, $_go
_go:
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es

    ###############################
    ## disable interrupt
    cli

    ###############################
    ## load system
    pushw $SYSTEM_SEG
    pushw $SYSTEM_NR_SECTORS
    pushw  $SYSTEM_SECTOR1
    call _load_system
    addw $6, %sp


    ###############################
    ## init GDT
    lgdt __gdt48_boot 

    ###############################
    ## jump into protected mode
    smsw %ax
    orw $0x01, %ax
    lmsw %ax

    ljmp $CODE_SEG, $_start32

_idle:
    hlt
    jmp _idle

############################### 
## Function : _load_system
## Input    : (start_sector, nr of sector, vma_seg) - limitation: nr of sector should be less than 65535
## Output   : none
## Desc     : in real mode
.type _load_system, @function
_load_system:
    pushw %bp
    movw %sp, %bp
    
    movw 6(%bp), %ax
    movw $HD0_COUNTER_PORT, %dx
    outb %al, %dx

    movw 4(%bp), %ax
    movw $HD0_ADDR1_PORT, %dx
    outb %al, %dx
    movw $HD0_ADDR2_PORT, %dx
    movb %ah, %al
    outb %al, %dx

    movb $0, %al
    movw $HD0_ADDR3_PORT, %dx
    outb %al,  %dx

    movb $LBA28_DEVICE_MASTER, %al
    movw $HD0_DEVICE_PORT, %dx
    outb %al, %dx

    movb $CMD_READ, %al
    movw $HD0_CMD_PORT, %dx
    outb %al, %dx

_data_ready_checking:
    .word 0x00eb
    inb %dx, %al
    andb $0x88, %al
    test $0x08, %al
    jz _data_ready_checking

_data_reading:
    movw 6(%bp), %cx
    shl $0x8, %cx
    movw 8(%bp), %ax
    push %es
    movw %ax, %es
    xor %di, %di
    movw $HD0_DATA_PORT, %dx

_next_word:
    inw %dx, %ax
    movw %ax, %es:(%di)
    addw $0x02, %di
    loop _next_word

    pop %es

    movw %bp, %sp
    popw %bp
    ret
.size _load_system,.-_load_system

.section .data
__gdt_boot:
.long 0,0

.long 0x0000FFFF, 0x00409a09 # CS 32bits
.long 0x0000FFFF, 0x00409209 # DS 32bits
.long 0x0000FFFF, 0x00409609 # SS 32bits - ExpandDown 0x200000
.long 0x80007FFF, 0x0040920B # ES 32bits - Video

.long 0x0000ffff, 0x008f9200 # DS 0-4G RW

__gdt48_boot:
## LIMIT is the total len minus 1 
.word .-__gdt_boot-1
## THIS is VERY IMPORTANT that we have to specify the 'absolute physical address' for GDT
.long __gdt_boot + (BOOT_SEG<<4)

