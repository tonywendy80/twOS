[toc]

本章节主要的学习任务有：
1. 学会使用 as86，ld86等build工具
2. 学会as86的语法
3. 了解as86和GNU as语法上的不同点
4. 创建第一个OS雏形，在屏幕上打出‘Hello My OS'

请各位看官相信自己，本章不难，就是知识点多点而已，仅此而已！ 加油小宝贝们！！！

# build tool
If you're runing on Redhat Linux, you can utilize package tool 'yum' to install dev86 which contains the build tool chains, as86, ld86, bcc and objdump86.

as86  is an assembler for the 8086..80386 processors.

使用man你可以得到详细的命令使用文档。

# as86
#### command usage
as86 -0 //build 16bits code for 8086
as86 -3 //build 32bits code for 80386 and higher
as86 -o obj //output

#### language grammar
|Item|Desc|
|---|---|
| ! | comments|
 #0x1234 | 立即数 |
| ax| 寄存器|
| * | Address of the start of the current line. |
|[]|Specify an indirect operand|
|.text .data .bss | section |
| entry | |
| .globl | define label as external |
| DB .BYTE ||
| DW .SHORT .WORD|.WORD 0xAA55|
| DD .LONG ||
| .ASCII ||
| .ASCIZ | Ascii string copied to output with trailing nul byte |
| .COMM .LCOMM ||
| EQU | VIDEO_SEG EQU 0xb800|
| SET | VIDEO_SEG SET 0xb800|
| .ORG |.org 510|
|SEG||
|CSEG/DSEG/ESEG/GSEG||


#### 寻址（addressing）
- **直接寻址**
    ！the jump copies bx into PC(*Program Counter*)
    mov ax, bx
    jmp bx

- **简单的间接寻址**
    ! the jump moves to the contents of bx into PC.
    mov ax, [bx]
    jmp [bx]

- **简单的直接寻址**
    mov ax, #0x1234   ！ax = 0x1234

- **又一个间接寻址**
    mov ax, 0x1234
    mov ax, [0x1234]
    mov ax, _hello
    mov ax, [_hello]  ! ax <- the content in address _hello

- **真的，最后一个间接寻址(indexed addressing)**
    mov ax, _table[bx]
    mov ax, _table[bx+si]
    mov eax, _table[ebx*4]

#### 约定
如果使用as86的话，源文件是以 .S 为后缀。
如果使用GNU as的话，源文件以 .s 为后缀。


# ld86



