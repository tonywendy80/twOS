/*
** Author : tonyma
** Date   : 2022-5-20
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
    .data :
    {
        *(.data)
    }
    .BOOT_FLAG 510 :
    {
        SHORT(0xAA55)
    }
}
