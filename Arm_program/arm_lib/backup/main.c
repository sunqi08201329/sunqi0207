//#include "uart.h"
//#include "nand.h"
//#include "lcd.h"
//#include "led.h"

//#define GPH2CON  (*(volatile unsigned int *)0xE0200C40)
//#define GPH2DAT  (*(volatile unsigned int *)0xE0200C44)

//#define BUFSIZE 1024

//int mymain(void)
//{
	//char buf[BUFSIZE];
	//uart_init();
	//while(1){
		//uart_gets(buf);
		//uart_puts("\n\r");
		//uart_puts(buf);
	//}
	////uart_puts("hello,world\n\r");
	////uart_printdec(1000);
	////uart_puts("\n\r");
	////uart_printhex(1000);
	////uart_puts("\n\r");
	////uart_printf("%s\t%d\t%x","asdasd", 1000, 1000);
	////uart_puts("\n\r");
	////while(1){
	//////c = uart_getchar();
	//////uart_putchar(c);
	////}
	////while(1){
		////char c;
		////for (c = 'a'; c <= 'z'; c++) 
		////{
		////uart_putchar(c);
		////delay(1000000);
		////}
		////}
	//return 0;
//}
