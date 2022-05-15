
ENTRY(_start)
_stack = 0x400;
SECTIONS
{
    . = 0x00;
    .text : 
    {
        *(.text)
    }
    .rodata :
    {
        *(.rodata)
    }

    .boot_flag 510 : 
    {
        SHORT(0xAA55)
    }
}
