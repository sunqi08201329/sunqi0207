#include "uart.h"

#define GPA0CON 	(*(volatile unsigned int *)0xE0200000)

#define ULCON0 		(*(volatile unsigned int *)0xE2900000)
#define UCON0 		(*(volatile unsigned int *)0xE2900004)

#define UTRSTAT0 	(*(volatile unsigned int *)0xE2900010)

#define UTXH0 		(*(volatile unsigned int *)0xE2900020)
#define URXH0 		(*(volatile unsigned int *)0xE2900024)

#define UBRDIV0 	(*(volatile unsigned int *)0xE2900028)
#define UDIVSLOT0 	(*(volatile unsigned int *)0xE290002C)


void uart_init(void)
{
	GPA0CON &= ~(0xFF << 0);   
	GPA0CON |= (0x22 << 0);   


	ULCON0 	  = 0x3;
	UCON0 	  = 0x5;


	UBRDIV0 = 0x23;  
	UDIVSLOT0 = 0xDDDD;
}
char uart_getchar(void)
{
	char c;
	while(!(UTRSTAT0 & (0x1 << 0)))
		;
	c = URXH0;	

}
void uart_putchar(char c)
{
	while(!(UTRSTAT0 & (0x1 << 2)))
		;
	UTXH0 = c;	
}
void uart_puts(char *str)
{
	if(*str == 0){
		uart_putchar('\n');
		return;
	}
	while(*str){
		uart_putchar(*str);
		str++;
	}
	
}
void uart_printdec(int data)
{
	int temp1, temp2;
	temp1 = data / 10;
	temp2 = data % 10;
	if(temp1)
		uart_printdec(temp1);
	uart_putchar(temp2 + '0');
}
void uart_printhex(int data)
{
	int i, temp;
	uart_putchar('0');
	uart_putchar('x');
	for (i = 7; i >= 0; i--) 
	{
		temp = (data >> (i * 4)) & 0xF;
		if(temp < 10)
			uart_putchar(temp + '0');
		else
			uart_putchar(temp - 10 + 'A');
	}
}
void uart_printf(const char * format, ...)
{

    int num = 1;
    int data;
    char ch;
    char *str;
    int *sp = (int *)&format;
    char *fstr = (void *)format;

    while (*fstr)
    {
        while((*str != 0) && (*fstr != '%'))
        {
            uart_putchar(*fstr++);
        }
        if (*str == 0)
            return;

        fstr++; 
        switch (*fstr++)
        {
        case '%':
            uart_putchar('%');
            break;
        case 'd':
            data = *(sp + num++);
            uart_printdec(data);
            break;
        case 'c':
            ch = *(char *)(sp + num++);
            uart_putchar(ch);
            break;
        case 'S':
        case 's':
            str = (char *)(*(sp + num++));
            uart_puts(str);
            break;
        case 'x':
        case 'p':
            data = *(sp + num++);
            uart_printhex(data);
            break;
        default:
            uart_puts("\nformat string error!\n");
            return;
        }

    }
}

