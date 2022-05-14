[toc]

本章节主要的学习任务有：
1. 学会使用 as86，ld86等build工具
2. 学会as86的语法
3. 了解as86和GNU as语法上的不同点
4. 创建第一个OS雏形，在屏幕上打出‘Hello My OS!'

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
|Item|Desc|Comments|
|---|---|---|
| ! | comments||
 #0x1234 | 立即数 ||
| ax| 寄存器||
| * | Address of the start of the current line. ||
|[ ]|Specify an indirect operand||
|.text .data .bss | section ||
| entry | | |
| .globl | define label as external | |
| DB .BYTE || |
| DW .SHORT .WORD|.WORD 0xAA55| |
| DD .LONG || |
| .ASCII || |
| .ASCIZ | Ascii string copied to output with trailing nul byte | |
| .COMM .LCOMM || |
| EQU | VIDEO_SEG EQU 0xb800| |
| SET | VIDEO_SEG SET 0xb800| |
| .ORG |.org 510| 把LC(location counter)放在510处|
|SEG|||
|CSEG/DSEG/ESEG/GSEG|||


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
    ld86 -0 // for 8086
    ld86 -s //strip all symbols
    ld86 -o <output> //output
    ld86 -T<base>  // specify the base address for .text section
    ld -D <base> // specify the base address for .data section

# objdump86
此处不想展开太多。 详细的使用方法，请参考手册或自行搜索。
    
    objdump86 boot

# dd

    dd if=<input file> of=<output file> bs=<block size> count=<count of blocks> skip=<skip bytes of input file> seek=<skip bytes of output file> 

也可以使用`man dd`查看更多详情。

# Makefile
在此我就不展开讲如何写Makefile了，其实我们只要知道Makefile的原理和最简单的语法就好了，想那些double colon啦，静态模式之类的不想学，暂时可以不用学。
如果有兴趣可以自行搜索。 或者在linux环境中用 `info make` ，有很详细的介绍。

在此，我就提一句最简单，最通用的语法规则：

     TARGETS : PREREQUISITES
             RECIPE
             ...

请注意，RECIPE之前的是 TAB， 而不是空格。 切记！！！


# BUILD
- 直接make，就可以看到最终的boot.bin
- 然后把他copy到你的bochs的目录下，配置好bochs配置文件，执行起来就好了。 有关于如何使用bochs，我会单独出一期来讲述bochs的用法。
- 链接好以后你会发现boot大小为512+32bytes；为啥？
    * 一方面是bootsect.S里面的 `.org 510`设定的
    * 一方面是可执行文件的头大小 32bytes
    * 你可以用 `objdump86 -S boot`查看
- 使用`dd`可以把执行文件头移除。


# 雏形效果
![DEMO of OS](%E9%9B%8F%E5%BD%A2%E6%95%88%E6%9E%9C.png "刚孵化出来")


# Note
- 有关于VIDEO Memory的知识点，以后章节中会慢慢提及。对于CGA来说字符是存储在0xb8000内存地址开始处的，写什么就显示什么。
- 字符如何组织？ 简单！ 就是用两个字节表示一个字符。 例如0x0241 高字节02是字符属性， 低字节41是字符ascii码。
- 字符属性字节格式： 0xlbbbifff   
    * l位 代表blink
    * bbb位 代表background color
    * i位 代表highlight位 （1 - 颜色变浅）
    * fff位 代表foreground color也就是字符颜色

