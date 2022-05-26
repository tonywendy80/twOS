################################
## Author : tonyma
## Date   : 2022-05-27
## Email  : tonywendy80@qq.com
##
## All rights reserved by tonywendy80
##############################################

BOOT_SEG   = 0x07c0
VIDEO_SEG  = 0xb800

CHAR_ATTR = 0x02   # GREEN
SEMICOLON = 0x043a # Red :


# TIMER Format: HH:MM:SS
TIMER_OFF = 15*80+32
HOUR_OFF  = TIMER_OFF
MIN_OFF   = HOUR_OFF + 3
SEC_OFF   = MIN_OFF + 3

.globl _start

.code16
.section .text
_start:
    ljmp $BOOT_SEG, $_go
_go:
    movw %cs, %ax
    movw %ax, %ds

    movw $VIDEO_SEG, %ax
    movw %ax, %es

    ###############################
    ## disable interrupt
    cli

    ###############################
    ## show the current time
    movw $0x80, %ax
    outb %al, $0x70
    inb $0x71, %al
    pushw %ax

    movb $0x82, %al
    outb %al, $0x70
    inb $0x71, %al
    pushw %ax

    movb $0x84, %al
    outb %al, $0x70
    inb $0x71, %al
    pushw %ax

    call _print_time
    add $6, %sp


    ###############################
    ## setup RTC interrupt
    pushw %es
    movw $0, %ax
    movw %ax, %es
    movw $0x70, %di
    shl $2, %di
    movw $_rtc_int_handler, %es:(%di)
    addw $2, %di
    movw %cs, %es:(%di)
    popw %es

    movb $0x8b, %al
    outb %al, $0x70
    inb $0x71, %al
    movb $0x12, %al
    outb %al, $0x71

    movb $0x0c, %al
    outb %al, $0x70
    inb $0x71,  %al

    inb $0xa1, %al    # 0xa1 -- 8259 IMR
    andb $0xfe, %al
    outb %al, $0xa1

    ###############################
    ## enable interrupt
    sti


_idle:
    hlt
    jmp _idle

###############################
## Function : _print_time
## Input    : (unsigned char hour, unsigned char min, unsigned char sec)
## Output   : none
.type _print_time, @function
_print_time:
    pushw %bp
    movw %sp, %bp
    pushw %bx
    
    ## HOUR
    pushw 4(%bp)
    call _bcd_to_ascii
    movw %ax, %bx
    add $2, %sp

    pushw $HOUR_OFF
    movb $CHAR_ATTR, %ah
    movb %bh, %al
    pushw %ax
    call _put_char
    add $4, %sp

    pushw $HOUR_OFF+1
    movb $CHAR_ATTR, %ah
    movb %bl, %al
    pushw %ax
    call _put_char
    add $4, %sp

    pushw $HOUR_OFF+2
    pushw __semicolon
    call _put_char
    add $4, %sp

    ## MIN
    pushw 6(%bp)
    call _bcd_to_ascii
    movw %ax, %bx
    add $2, %sp

    pushw $MIN_OFF
    movb $CHAR_ATTR, %ah
    movb %bh, %al
    pushw %ax
    call _put_char
    add $4, %sp

    pushw $MIN_OFF+1
    movb $CHAR_ATTR, %ah
    movb %bl, %al
    pushw %ax
    call _put_char
    add $4, %sp

    pushw $MIN_OFF+2
    pushw __semicolon
    call _put_char
    add $4, %sp


    # SECOND
    push 8(%bp)
    call _bcd_to_ascii
    movw %ax, %bx
    add $2, %sp

    pushw $SEC_OFF
    movb $CHAR_ATTR, %ah
    movb %bh, %al
    pushw %ax
    call _put_char
    add $4, %sp

    pushw $SEC_OFF+1
    movb $CHAR_ATTR, %ah
    movb %bl, %al
    pushw %ax
    call _put_char
    add $4, %sp


    popw %bx
    movw %bp, %sp
    popw %bp
    ret 
.size _print_time, .-_print_time


###############################
## Function : _put_char
## Input    : (char c, unsigned pos)
## Output   : none
.type _put_char, @function
_put_char:
    pushw %bp
    movw %sp, %bp
    pushw %di

    movw 4(%bp), %ax

    movw 6(%bp), %di
    shl $1, %di
    movw %ax, %es:(%di)

    popw %di
    movw %bp, %sp
    popw %bp
    ret
.size _put_char, .-_put_char



###############################
## Function : _bcd_to_ascii
## Input    : (char bcd)
## Output   : none
.type _bcd_to_ascii, @function
_bcd_to_ascii:
    pushw %bp
    movw %sp, %bp

    movw 4(%bp), %ax
    movb %al, %ah
    shr $4, %ah
    andw $0x0f0f, %ax
    addw $0x3030, %ax

    movw %bp, %sp
    popw %bp
    ret
.size _bcd_to_ascii, .-_bcd_to_ascii


_rtc_int_handler:
    movw __semicolon, %ax
    xorb $0x08, %ah
    movw %ax, __semicolon

    movw $0x80, %ax
    outb %al, $0x70
    inb $0x71, %al
    pushw %ax

    movb $0x82, %al
    outb %al, $0x70
    inb $0x71, %al
    pushw %ax

    movb $0x84, %al
    outb %al, $0x70
    inb $0x71, %al
    pushw %ax

    call _print_time
    add $6, %sp

    # READ RTC Register C
    movb $0x0c, %al
    outb %al, $0x70
    inb $0x71, %al
    movb %al, (508)

    # SEND EOI
    mov $0x20, %al
    outb %al, $0xa0
    outb %al, $0x20
    iret

.section .data
__semicolon:
.word SEMICOLON

