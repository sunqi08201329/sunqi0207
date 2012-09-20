
#include "uart.h"


void md(char * sdram_addr, int size)
{
	int lines = size / 16;
	int i, j;
	
	for (i = 0; i < lines; i++)
	{
		uart_printhex((int)sdram_addr);
		uart_puts(": ");
			
		for (j = 0; j < 16; j++)
			uart_printhex(sdram_addr[i*16+j]);			
		
		uart_puts("\n\r");
	}
}


void delay(int num_cycle)
{
	int i;
	for (i = 0; i < num_cycle; i++) 
		;
}
