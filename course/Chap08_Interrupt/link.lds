/*
** Author : tonyma
** Date   : 2022-5-26
** File   : link.lds
** All rights reserved by tonywendy80@qq.com
*/


/*
**  SYSTEM SIZE = 1 page
*/
SYSTEM_VMA_BEG = 0x0000;
SYSTEM_VMA_END = 0x1000;

ENTRY(_start)

SECTIONS
{
    . = 0x00;
    .boot.text :
    {
        boot.o(.text)
    }
    .boot.data :
    {
        boot.o(.data)
    }
    .BOOT_FLAG 510 :
    {
        SHORT(0xAA55)
    }
    .text SYSTEM_VMA_BEG : AT(ADDR(.BOOT_FLAG)+SIZEOF(.BOOT_FLAG)) 
    {
        *(EXCLUDE_FILE(boot.o) .text)
    }
    .data :
    {
        *(EXCLUDE_FILE(boot.o) .text)
    }
    SYSTEM_VMA_END -= 2;
    .END_FLAG SYSTEM_VMA_END : 
    {
        SHORT(0xDEAD)
    }
}
