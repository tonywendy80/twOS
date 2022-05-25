/*
** Author : tonyma
** Date   : 2022-5-25
** File   : lesson.lds
** All rights reserved by tonywendy80@qq.com
*/

ENTRY(_start)

SECTIONS
{
    . = 0x00;
    .text :
    {
        *(.text)
    }
    .BOOT_FLAG 510 :
    {
        SHORT(0xAA55)
    }
    .data :
    {
        *(.data)
        *(.rodata)
    }
    .end_of_2ndsect 1022 :
    {
        SHORT(0xDEAF)
    }
}
