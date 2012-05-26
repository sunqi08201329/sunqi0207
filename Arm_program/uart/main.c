#include "uart.h"

int mymain(void)
{
	char c;
	uart_init();
	//uart_puts("hello,world\n\r");
	uart_printdec(1000);
	uart_puts("\n\r");
	uart_printhex(1000);
	uart_puts("\n\r");
	uart_printf("%s\t%d\t%x","asdasd", 1000, 1000);
	uart_puts("\n\r");
	while(1){
		//c = uart_getchar();
		//uart_putchar(c);
	}
	return 0;
}
