[toc]

本章学习的主要目标：

    1. 什么是保护模式？
    2. 如何开启保护模式？ CR0
    3. 什么是段 segment？
    4. 段格式: 代码段，数据段，系统段
    5. 段限长检查
    6. 段优先级检查
    7. 段选择符
    8. GDT LDT IDT

本章内容比较多，主要就是INTEL CPU方面的知识，还是比较重要的。大家可以多花点精力，不清楚的地方可能还需要你网上多多查找有关资料，或者写代码在虚拟机BOCHS或者QEMU上验证下。


# 保护模式 vs 实地址模式

保护模式有更好的隔离：
- 用户空间和内核空间不相互影响； 
- 两个应用程序之间不相互影响；

|Item|Real Mode|Protected Mode|
|---|---|---|
|地址计算方式|(CS<<4)+IP|CS(selector) -> DT -> Base + IP|
|段LIMIT|64K|基于段描述符里的LIMIT字段和G字段|
|权限||优先级检查|


# 保护模式开启之路

    开启保护模式很简单，主要就是利用控制寄存器 CR0.PE[bit0]. 格式如下：

![CR0](CR0.png)

实现方法1：

        movl %CR0, %eax
        orl $0x0001, %eax
        movl %eax, %CR0
    
实现方法2:

        smsw %ax
        orw $0x0001, %ax
        lmsw %ax


# 段格式
![Segment Descriptor](segment_descriptor.png)




# 段限长检查


# 段优先级检查


# 段选择符 SELECTOR
- 代码实现中通过段寄存器(CS,DS,ES,FS,GS,SS)来选择段的
- 而段是通过段选择符来选中的
- 所以CS,DS中显式部分村的是SELECTOR，而隐式部分才存的是描述符。

![SELECTOR](Selector.png)

如何加载段选择符？

        1. mov %ax, %ds

        2. lds m16:32, r32

        3. ljmp $SEL, $IP


Note:
* [x] 不能mov到CS


# GDT LDT IDT


# Note
- **Segment** is totally different from the **Section** used in object file.


# 一个小小DEMO
- 因为不想牵涉到磁盘数据读写，所以尽量会把代码集中在一个扇区大小(0x200)。这样 BIOS直接就会把代码Download到0x7c00处执行了。一个字，省事儿！！！ 嗯？几个字？
    
- 主要使用GNU AS来实现。


# 有一个小小DEMO
