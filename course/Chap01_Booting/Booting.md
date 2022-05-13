[toc]

## The CPU initial satus after booting up

> 为啥一上来就先把数据都摆上来，更何况估计有些同学还没有入门呢，对有些寄存器还有些陌生。岂不是欺负人吗？ 非也！ 21世纪什么最重要，人才！那学习计算机什么最重要？当然是经过验证的数据；所以第一时间要先呈现给各位看官，
而且更容易查找。这里有对寄存器不懂的同学，请自行网上搜索，相信难不倒大家！


|Register|Value|
|-|-|
|EFLAGS|00000002H|
|EIP|0000FFF0H|
|CR0|60000010H|
|CR2,CR3,CR4|00000000H|
|CS| Selector = F000H  Base = FFFF0000H  Limit = FFFFH AR = Present, R/W, Accessed |
|SS,DS,ES,FS,GS| Selector = 0000H  Base = FFFF0000H  Limit = FFFFH  AR = Present, R/W, Accessed|
|EAX/EBX/ECX|0|
|ESP/EBP|0|
|ESI/EDI|0|
|GDTR|Base = 00000000H Limit = FFFFH AR = Present, R/W|
|IDTR|Base = 00000000H Limit = FFFFH AR = Present, R/W|
|LDTR|Selector = 0000H Base = 00000000H Limit = FFFFH AR = Present, R/W|
|Task Reg|Selector = 0000H Base = 00000000H Limit = FFFFH AR = Present, R/W|
|IA32_EFER|0|

## 计算机咋跑起来呢？起跑线在哪儿呢？
> 其实计算机运行没那么神秘？一句话的事：CPU获取指令和数据后，放在ALU中执行。
> so easy!
> 起跑线呢？去哪儿找指令和数据啊？

> 当计算机启动后第一条指令地址就是0xFFFFFFF0，约定俗成？ 
> 其实，根据Intel手册（上面的这个表中数据就是从Intel手册摘录而来），我们发现 CS=F000 IP=FFF0，而且CPU此时是处于实地址模式。按照实地址模式的计算方式，最终物理地址应该是 CS<<4 + IP,也就是0xFFFF0. 为啥是0xFFFFFFF0? 好奇宝宝是不是很好奇？

> 其实啊，做过Bootloader的同学们可能都知道其中奥妙。不过不乏有些刚入门的同学感觉到疑惑，我也是经历了很长时间的困惑才弄明白。各位看官们，请听我慢慢道来。

> 大家看过Intel手册就会发现，取指令的话我们需要CS:IP对；取数据的话，我们需要DS:SI或者其他方式。实地址模式下地址的计算也都明白。 可是结果是0xFFFF0而不是0xFFFFFFF0，矛盾啊！ 其实啊对于段寄存器来说，有两部分组成：一部分是显式部分，就是我们看到CS中的值；另一部分是隐式部分，例如baseaddress。

> 当CPU开始执行第一次Jmp后，他才开始用实地址的计算方式算出基地址，存在于CS的隐式部分中。以后不用再计算，除非CS变化。

> 这样就明白了，在jmp之前，指令的基地址为啥是0xFFFFFFF0了吧。 不矛盾了吧！ 基地址是预设成0xFFFFFFF0,和实地址计算方式不矛盾。


## 计算机开始执行

既然0xFFFFFFF0是第一个执行的指令存放出，那么我们的代码应该放在这里吗？

非也！ 这些是BIOS的地盘，BIOS要做很多事情呢？
做完后才轮到我们？ 

那我们在哪里啊？ 走，去0x7c00处！！！

请记住 0x7c00 才是我们的家，我们发家致富的开始的地方！！！

所以以后boot代码要定位到这个地方，build的时候我们就会看到我们需要把代码链接 基地址定位到0x7c00.

让我们一起期待下一节的一个小demo，揭示怎么build这个小小的不会走路的系统雏形，怎么被CPU执行起来？
