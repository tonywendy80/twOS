################################
## Author : tonyma
## Date   : 2022-05-25
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################


## in Real-mode
BOOT_SEG  = 0x07c0
VIDEO_SEG = 0xb800

HD_BASE_IOPORT = 0x1f0
HD_DATA = HD_BASE_IOPORT
HD_ERROR = HD_BASE_IOPORT + 1
HD_NRSECT = HD_BASE_IOPORT + 2
HD_ADDR1 = HD_BASE_IOPORT + 3
HD_ADDR2 = HD_BASE_IOPORT + 4
HD_ADDR3 = HD_BASE_IOPORT + 5
HD_DEVICE = HD_BASE_IOPORT + 6
HD_CMD = HD_BASE_IOPORT + 7
HD_STATUS = HD_CMD

CHS_MODE_MASTER = 0xa0
CHS_MODE_SLAVE = 0xb0

LBA28_MODE_MASTER = 0xe0
LBA28_MODE_SLAVE = 0xf0

LBA48_MODE_MASTER = 0x40
LBA48_MODE_SLAVE = 0x50

READ = 0x20
WRITE = 0x30

MEM_SEG = 0x1000
MEM_OFF = 0x0000

.globl _start
.section .text
_start:
    .code16
    ljmp $BOOT_SEG, $_go
_go:
    movw %cs, %ax
    movw %ax, %ds

    movw $MEM_SEG, %ax
    movw %ax, %es

    pushw $1        ## nr. of sectors
    pushw $1        ## starting sector
    pushw $MEM_OFF  ## DEST MEM 
    call _load_sector_lba28
    add $6, %sp

_die: 
    jmp _die

#################################
## Function : _load_sector_lba28
## Input    : (unsigned short mem, unsigned short start_sector, unsigned char nr_sectors)
## Return   : unsigned short - the number of sectors having been read into memory
.type _load_sector_lba28,@function
_load_sector_lba28:
    pushw %bp
    movw %sp, %bp

    movw 8(%bp), %cx
    cmp $0, %cx
    jz _end_of_load

    movb %cl, %al
    movw $HD_NRSECT, %dx
    outb %al, %dx

    inc %dx
    movw 6(%bp), %ax
    outb %al, %dx

    inc %dx
    movb %ah, %al
    outb %al, %dx

    inc %dx
    movb $0, %al
    outb %al, %dx

    movb $LBA28_MODE_MASTER, %al
    inc %dx
    outb %al, %dx

    movw $HD_CMD, %dx
    movb $READ, %al
    outb %al, %dx

_await_result:
    inb %dx, %al
    andb $0x88, %al
    cmp $0x08, %al
    jnz _await_result

    shl $8, %cx
    movw 4(%bp), %di
    movw $HD_DATA, %dx
_read_word:
    inw %dx, %ax
    movw %ax, %es:(%di)
    add $2, %di
    loop _read_word


_end_of_load:
    movw %bp, %sp
    popw %bp
    ret
.size _load_sector_lba28,.-_load_sector_lba28


.section .data
__msg:
.ascii "Hi Mark, Sorry that  I am offline around that time."
.ascii "Just logged in to your system and found the OBJECT configured in your certificate as below;"
.ascii "Could you please adjust it and have another try?"
.ascii "Thank"
.byte 0

