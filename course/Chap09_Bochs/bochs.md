[toc]

本章的主要目的是为了展示如何使用bochs来调试代码。

说白了，也就是介绍bochs的命令如何使用。
列出了所有常用的命令，以方便查询。

主要包括以下几个常见用途:
- help
- break 设置
- 查看寄存器
- symbol符号加载和使用


# help
- help
- help \<topic\>
- show
- trace

# break
- pb|b 0x7c00
- lb 0x0f
- vb 0x07c0:0x0000
- blist
- info b
- d|del \<num\>

```
<bochs:6> info b
Num Type           Disp Enb Address
  1 vbreakpoint    keep y   0x07c0:000000000000000f 
  2 pbreakpoint    keep y   0x000000007c00
  3 pbreakpoint    keep y   0x0000000007c5

<bochs:60> pb '_go'

```

# info查看
- info cpu
- info flags
- info gdt
- info ldt
- info idt
- info tss
- info tab
- info symbols
- info device 
- info device pic


# 查看数据
- r | reg
- sreg
- creg
- mmx
- xmm | sse
- print-stack
- x /nuf \<linear addr\>
- xp /nuf \<physical addr\>
- ? | calc \<expr\>

# 设置数据
- setpmem \<addr\> \<datasize\> \<val\>

# 查看汇编源码
```
u /n 0x7c00
u /n '_startup'

```

# symbol使用
- slist
- ldsym [global] \<filename\> [offset] - load symbols from file

```
<bochs:58> ldsym 'boot.sym' 0x07c0
<bochs:59> slist
             7c0: BOOT_SEG
             7c1: SYSTEM_FIRST_SECTOR
             7c2: CHAR_ATTR
             7c5: _go
```

怎么生成sym文件呢？
其实很简单，只要用nm这个linux命令就好了，但是还需要后续的处理如下：
```
nm boot | awk '{ PRINT $1 " " $3}' >boot.sym
```
因为sym文件格式是： `addr sym` of each line
```
00009128 __gdt
00009178 __gdt48
000000b6 __gdt48_boot
00000086 __gdt_boot
00000005 _go
0000900e _go32
```

# Specials
- trace \< on | off \>
- show \< int | call | off | all | ... \>

