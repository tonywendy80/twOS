!!! 注释
!!! Author : tonyma
!!! Date   : 2022-05-13 (lockdown at home due to the pandamic)

!!! Writen by as86 from dev86

VIDEO_SEG EQU 0xb800
BOOT_SEG EQU 0x07c0

.data

.bss

.text
entry start
start:
    jmpi _go, BOOT_SEG
_go:
    mov ax, cs
    mov ds, ax
    mov ax, #VIDEO_SEG
    mov es, ax
    
    ! clean the screen
    xor di, di
    xor si, si
    mov ax, #0x0200 ! set the foreground-color to GREEN
    mov cx, #25*80  ! one page: 25x80 (hxw)
_repeat_clean_screen:
    seg es ! equal to ESEG
    mov [di], ax
    add di, #2
    loop _repeat_clean_screen

    ! write MSG to the begin of the sreen
    xor di, di
    xor si, si
    mov cx, MSG_LEN
_repeat:    
    mov al, MSG[si]
    ESEG
    mov [di], al
    inc si
    add di, #2
    loop _repeat
    
    ! whileloop
_die:
    jmp _die

MSG:
.ASCIZ "Hello, My OS!"
MSG_LEN:
.byte *-MSG

.org 510
.word 0xAA55 ! boot sector flag, validated by BIOS when loading to memory

