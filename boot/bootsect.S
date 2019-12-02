! this is boot sector as demo

.globl begtext,begdata,begbss,endtext,enddata,endbss

BOOTSEG = 0x07c0

.text
begtext:
.data
begdata:
.bss
begbss:


.text
entry _start
	jmpi _start, BOOTSEG
	
_start:
	mov ax, cs
	mov ds, ax
	mov es, ax

	mov bp, #msg
	mov dx, #0x1205
	mov bx, #0x000c
	mov cx, len
	mov ax, #0x1301
	int 0x10


_end:
	jmp _end


msg:
	.ascii "hello world ..."
	.byte 0x0d, 0x0a
len:
	.word 17

	.org 510
	.word 0xaa55

.text
endtext:
.data
enddata:
.bss
endbss:
