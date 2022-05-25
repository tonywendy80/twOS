[toc]


本章的主要内容就是有关于硬盘控制器的编程操作！

这一章还是比较重要的，以后的FS会用到。

另外由于性能问题，CPU和HD之间的数据交互怎么处理呢？

CPU速度超快，可是硬盘读写比较慢 - 这是事实！ 难道让CPU在那儿等？
还是用 INERRUPT， 读写一个block 发个中断？

答案是 DMA + Interrupt ! 

正是由于性能差异，所以又牵扯出了另外一个重要概念，多进程读写HD：
一个Process A读数据的时候，就会把CPU资源交出去，然后另外一个Process B也读区同样的数据，那也需要等待！ 这样就必须要正确处理好等待队列和进程间同步和信号通知的问题。

本章主要内容包括：

    1. 硬盘基本知识
    2. 硬盘寄存器介绍
    3. 读写硬盘数据
    4. 寻址方式



# 硬盘基本知识
- 硬盘的磁头 H: 0~...
- 硬盘的磁道 C: 0~...
- 硬盘的扇区 H: 1~63

- 硬盘寻址方式
    1. CHS模式
    2. LBA模式 (Logical Block Addressing) - 扇区从0开始计数


# 硬盘控制器的寄存器
- **IDE0** <pre>0x1f0-0x1f7,0x3f6,0x3f7</pre>
- **IDE1** <pre>0x170-0x177,0x376,0x377</pre>

以IDE0为例：
|寄存器|端口|R/W|CHS|LBA28|LBA48|
|---|---|---|---|---|---|
|Data (16bits)|0x1f0|R/W|16bits|16bits|16bits|
|Error|0x1f1|R|8bits|8bits|16bits|
|Features|0x1f1|W|8bits|8bits|16bits|
|Sector Counter|0x1f2|W|8bits|8bits|16bits<br>1st write:high8bits<br>2nd write:low8bits)|
|Addr1|0x1f3|R/W|8bits<br>Starting Sector|8bits<br>LBA bit7-0|16bits<br>1st:bit31-24<br>2nd:bit7-0|
|Addr2|0x1f4|R/W|8bits<br>Cylinder Low-8bits|8bits<br>LBA bit15-8|16bits<br>1st:bit39-32<br>2nd:bit15-8|
|Addr3|0x1f5|R/w|8bits<br>Cylinder High-8bits|8bits<br>LBA bit23-16|16bits<br>1st:bit47-40<br>2nd:bit23-16|
|Device 8bits|0x1f6|R/W|8bits<br>M: 0b1010hhhh<br>S: 0b1011hhhh|8bits<br>M: 0b1110aaaa<br>S: 0b1111aaaa|8bits<br>M: 0x40<br>S: 0x50|
|Command (8bits)|0x1f7|W|8bits<br>Read:0x20<br>Write:0x30|8bits<br>Read:0x20<br>Write:0x30|8bits<br>Read:0x20<br>Write:0x30|
|Status (8bits)|0x1f7|R|8bits|8bits|8bits|
|Control (8bits)|0x3f6|W|8bits|8bits|8bits|
|Drive Address (8bits)|0x3f7|R|8bits|8bits|8bits|

Device Register:
|Mode|Bit7|Bit6<br>LBA mode|Bit5|Bit4<br>Master/Slave|Bit3-0|
|---|---|---|---|---|---|
|CHS|1|0|1|0: master<br>1: slave|hhhh: header|
|LBA28|1|1|1|0: master<br>1: slave|aaaa: LBA bit27-24|
|LBA48|0|1|0|0: master<br>1: slave|0000|

Status Register:
|Item/Name|Bit Indicator|Desc|
|---|---|---|
|ATA_SR_BSY    | 0x80    | Busy|
|ATA_SR_DRDY   | 0x40    | Drive ready|
|ATA_SR_DF     | 0x20    | Drive write fault|
|ATA_SR_DSC    | 0x10    | Drive seek complete|
|ATA_SR_DRQ    | 0x08    | Data request ready|
|ATA_SR_CORR   | 0x04    | Corrected data|
|ATA_SR_IDX    | 0x02    | Index|
|ATA_SR_ERR    | 0x01    | Error|

Error Register:
|Name|Bit|Desc|
|---|---|---|
|ATA_ER_BBK     | 0x80    | Bad block          |
|ATA_ER_UNC     | 0x40    | Uncorrectable data |
|ATA_ER_MC      | 0x20    | Media changed      |
|ATA_ER_IDNF    | 0x10    | ID mark not found  |
|ATA_ER_MCR     | 0x08    | Media change request|
|ATA_ER_ABRT    | 0x04    | Command aborted  |
|ATA_ER_TK0NF   | 0x02    | Track 0 not found |
|ATA_ER_AMNF    | 0x01    | No address mark |


# CHS 寻址
1. Send 0xA0 for the "master" or 0xB0 for the "slave", ORed with the Head Number to port 0x1F6: outb(0x1F6, 0xA0 | (slavebit << 4) | Head Number)

2. outb (0x1F2, bytecount/512 = sectorcount)

3. outb (0x1F3, Sector Number -- the S in CHS)

4. - outb (0x1F4, Cylinder Low Byte)
   - outb (0x1F5, Cylinder High Byte)

5. Send the "READ SECTORS" command (0x20) to port 0x1F7: outb(0x1F7, 0x20)


# LBA28 寻址

1. Send 0xE0 for the "master" or 0xF0 for the "slave", ORed with the highest 4 bits of the LBA to port 0x1F6: outb(0x1F6, 0xE0 | (slavebit << 4) | ((LBA >> 24) & 0x0F))

2. Send the sectorcount to port 0x1F2: outb(0x1F2, (unsigned char) count) -- A sectorcount of 0 means 256 sectors

3. - Send the low 8 bits of the LBA to port 0x1F3: outb(0x1F3, (unsigned char) LBA))
   - Send the next 8 bits of the LBA to port 0x1F4: outb(0x1F4, (unsigned char)(LBA >> 8))
   - Send the next 8 bits of the LBA to port 0x1F5: outb(0x1F5, (unsigned char)(LBA >> 16))

4. Send the "READ SECTORS" command (0x20) to port 0x1F7: outb(0x1F7, 0x20)

5. Wait for an IRQ or poll.

6. Transfer 256 16-bit values, a uint16_t at a time, into your buffer from I/O port 0x1F0. (In assembler, REP INSW works well for this.)

7. Then loop back to waiting for the next IRQ (or poll again -- see next note) for each successive sector.


# LBA48 寻址

1. Send 0x40 for the "master" or 0x50 for the "slave" to port 0x1F6: outb(0x1F6, 0x40 | (slavebit << 4))

2. - outb (0x1F2, sectorcount high byte)
   - outb (0x1F3, LBA4)
   - outb (0x1F4, LBA5)
   - outb (0x1F5, LBA6)

3. - outb (0x1F2, sectorcount low byte)
   - outb (0x1F3, LBA1)
   - outb (0x1F4, LBA2)
   - outb (0x1F5, LBA3)

4. Send the "READ SECTORS EXT" command (0x24) to port 0x1F7: outb(0x1F7, 0x24)