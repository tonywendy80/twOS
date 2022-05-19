
ENTRY(_start)
SECTIONS
{
    . = 0x00;
    .text : 
    {
        *(.text)
    }
}
