[toc]

本章主要就是实操 Exception && INTERRUPT！！！

非常重要的概念！ 在操作系统内部或者上层应用开发中，都是很重要的！

注意了，精神点！

主要内容包括:

    1. 什么是Exception？
    2. Exception分类: Fault & Trap & Abort
    3. 中断源: 软中断 CPU内部中断 外部中断(可屏蔽 不可屏蔽)
    4. IF标志
    5. Interrupt Gate and Trap Gate
    6. IVT IDT
    7. 中断处理过程
    8. PIC控制器
    9. RTC
    10.Timer 8042


# 异常
![exceptions](exceptions.png)



# 中断 IVT
存在物理地址为0的位置：
0x0000 CS:IP (4bytes)
0x0004 CS:IP (4bytes)
...

# 中断 IDT
通过lidt来装在中断描述符表。

example: 注意描述符表地址是实地址。

```
# load idtr
    lidt __idt48

__idt48:
    .word . - __idt - 1
    .long __idt + SYSTEM_VMA
```

# EFLAGS.IF (Bit9)
这个中断标志仅仅影响external interrupts，对于软中断和CPU内部中断无效。

# Interrupt Gate vs. Trap Gate
- 共同点是在中断处理程序中, TF = 0；
- 不同点是，在Interrupt Gate的处理程序中，IF = 0；而在Trap Gate处理程序中保持不变。



# 中断处理过程
- 关键点是stack的变化，stack要不要切换。

![Stack Changes](stack_change_4_interrupt.png)


# PIC
#### 8259A block
![block diagram](8259A_block.png)

#### 处理过程
- 中断请求到来，IRR相应位被锁存;
- 如果IMR中对应位没有值位，那么将会被送到PR中;
- PR选中最高优先级中断后，8259A将会向CPU发送INT信号;
- CPU完成当前指令后，向8259A发送一个响应信号INTA;
- 8259A收到后, 将会设置ISR中的对应位; 同时IRR中对应位清零;
- CPU发送第二个INTA信号;
- 8259A发送中断号到数据总线上供CPU读取;如果是AEOI模式，那么复位ISR对应位。

#### ICW1-4

###### ICW1
|A0|B7|B6|B5|B4|B3|B2|B1|B0|
|---|---|---|---|---|---|---|---|---|
| 0 | x | x | x | 1 | 边沿触发模式LT? | x | Single? | ICW4? | 

- 0x11 -> 0x20 master
- 0x11 -> 0xa0 slave

###### ICW2
> vector setting (A0 = 1) : high 5 bits
- 0x20 -> 0x21 master
- 0x28 -> 0xa1 slave

###### ICW3
> cascading setting (A0 = 1)
- 0x04 (bit2: IRQ2) -> 0x21 master
- 0x02 (2 : IRQ2) -> 0xa1 slave

###### ICW4
|Bit|Name|Description|
|---|---|---|
| 7 | 0 | 恒为0|
| 6 | 0 | 恒为0|
| 5 | 0 | 恒为0|
| 4 | SFNM | 1:特殊全嵌套模式|
| 3 | BUF| 1:缓冲方式|
| 2 | M/S| 1:缓冲方式下的master|
| 1 | AEOI| 1: 自动结束中断方式 |
| 0 | 微处理器uPM| 1: 8086/8088 0: MCS80/85 |


#### OCW1-3
###### OCW1 (A0=1) 
> Mask register, 可读写
- The master 8259A IRQ2 对应于整个slave 8259A，所以不能屏蔽掉。
- 高优先级位的设置不会影响低优先级的中断请求。

###### OCW2 (A0=0)
|Bit|Name|Description|
|---|---|---|
| 7 | R | rotate 循环|
| 6 | SL | specify level 指定中断|
| 5 | EOI | End of Interrupt: 使ISR相应位清零|
| 4 | 0 | 恒为0|
| 3 | 0 | 恒为0|
| 2 | L2 | 中断IRQ第三位|
| 1 | L1 | 中断IRQ第二位|
| 0 | L0 | 中断IRQ第一位|
- 0x20 : 一般EOI
- 0x6X : 特殊EOI
- 0xA0 : 循环一般EOI
- 0xEX : 循环特殊EOI
- 0xCX : 循环设定最低优先级

###### OCW3 (A0=0)
|Bit|Name|Description|
|---|---|---|
| 7 | - | |
| 6 | ESMM | Enable Special Mask Mode|
| 5 | SMM | Special Mask Mode|
| 4 | 0 | 恒为0|
| 3 | 1 | 恒为1|
| 2 | P | Poll|
| 1 | RR | Read Register|
| 0 | RIS | Read ISR|

- 读ISR (0x0b) or IRR (0x0a)
    ```
    movb $0x0b, %al     # 设置好“读ISR命令”
    outb %al, $0x20    # Write OCW3
    inb $0x20, %al　　  # 读ISR内容至AL中
    ```
- 设置特殊屏蔽模式(enable:0x60 or disable:0x40)
    ```
    movb $0x60, %al
    outb %al, $0x20
    ```
- 轮询中断信号


#### 优先级方式
- 固定优先级
- 循环优先级

#### 嵌套方式
- 一般全嵌套方式
- 特殊全嵌套方式

#### 触发方式
- 电平触发
- 边沿触发

#### 屏蔽方式
- 一般屏蔽方式
- 特殊屏蔽方式

#### 中断结束方式
- 自动中断结束方式
- 一般中断结束
- 特殊中断结束

#### 缓冲方式
- 缓冲方式
- 非缓冲方式

#### bochs如何查看PIC信息
```
<bochs:2> info device pic
i8259A PIC

master IMR = 00
master ISR = 01
master IRR = 05
master IRQ = 00
slave IMR = 00
slave ISR = 00
slave IRR = 01
slave IRQ = 00
```
- master IRR = 0x05 or 0b0101; which means signals on both IRQ0<->timer and IRQ2<->slave INTR
- slave IRR = 01; which means receiving signal from RTC


# RTC
参考basic.s查看如何使用RTC.

CMOS 内存信息:
|OFFSET|Content|
|---|---|
|0x00|Second|
|0x01|Alarm Second|
|0x02|Minute|
|0x03|Alarm Minute|
|0x04|Hour|
|0x05|Alarm Hour|
|0x06|Week|
|0x07|Day|
|0x08|Month|
|0x09|Year|
|0x0A|Register A; R/W|
|0x0B|Register B; R/W|
|0x0C|Register C; R|
|0x0D|Register D; R/W|

端口:
|Port|Desc|
|---|---|
|0x70|Index port|
|0x71|Data port|
- Index port的最高位控制NMI中断的开关；当MASK用。
- Bit7 = 1; Disable NMI
- Bit7 = 0; Enable NMI

Register B:
|Bit7|Bit6|Bit5|Bit4|Bit3|Bit2|Bit1|Bit0|
|---|---|---|---|---|---|---|---|
|Update Cycle Inhibit|Periodic Interrupt Enalbe|Alarm Interrupt Enable|Update Interrupt Enable|0|0: BCD<br>1: Binary|0: 12Hours<br>1: 24Hours|0|

Register C:
|Bit7|Bit6|Bit5|Bit4|Bit3-0|
|---|---|---|---|---|
|Interrupt Flag|Periodic Interrupt|Alarm Interrupt|Update Interrupt|0|
- **每次中断后一定要读RegisterC, 这样才会出发下次中断。**

#### bochs如何查看 RTC/CMOS 信息
```
<bochs:7> info device cmos
CMOS RTC

Index register: 0x0c

0000  09 00 17 00 18 00 05 30 06 22 26 12 00 80 00 00
0010  00 00 f0 00 06 80 02 00 7c 2f 00 0a 00 02 ff ff
0020  c0 0a 00 11 00 00 00 00 00 00 00 00 00 00 05 08
0030  00 7c 20 00 00 01 00 20 00 00 00 00 00 02 00 00
0040  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0050  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0060  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0070  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
<bochs:8> 
```

# PIT 8253/8254



