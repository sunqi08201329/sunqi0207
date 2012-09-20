#include "uart.h"

void go(int sdram_addr)
{
	((void (*)(void))sdram_addr)();
}
void help(void)
{
	uart_puts("help    - print command description/usage\n\r");
	uart_puts("go      - start application at address 'addr'\n\r");
}
