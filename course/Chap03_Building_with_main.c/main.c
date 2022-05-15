/*
 * File : main.c
 * Author: tonyma
 * Date : 2022-5-14
 * Email: tonywendy80@qq.com
 * /


/*
 * To enable 16bits code generation
 */
__asm__(".code16gcc\n");

#define ATTR_BLUE  0x01
#define ATTR_GREEN 0x02
#define ATTR_RED   0x04
#define ATTR_DEFAULT ATTR_GREEN

extern void clear_screen();

int putchar(char c, unsigned char attr)
{
    static unsigned short pos = 0;
    __asm__ __volatile__ ("movw $0xb800, %%bx\n\t"
        "movw %%bx, %%es\n\t"
        "stosw\n"
        :"+D"(pos)
        :"a"((unsigned short)(attr<<8)+c)
        :"%bx"
    );
}

int printf(const char* format,...)
{
    if( 0 == format )
        return -1;
    
    char c;
    const char *ptr = format;

    while( c = *ptr++ )
    {
        putchar(c, ATTR_DEFAULT);
    }
}

int main(int argc, char* argv[])
{
    const char* msg = "Hello, My OS!";

    clear_screen();
    printf(msg);
    return 0;
}
