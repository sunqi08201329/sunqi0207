#include "uart.h"
#include "lib.h"
#include "cmd.h"
#include "buzzer.h"
#include "nand.h"

#define LED_NAND_ADDR 0x100000
#define LED_DRAM_ADDR 0x23000000
#define LED_NAND_SIZE 0x100000
#define BUFSIZE 1024
#define CMDSIZE 10
#define PARMNUM 5
#define PARMLEN 32

void load_os(void);
void load_shell(void);

int mymain(void)
{
	int nand_addr;
	int sdram_addr;
	int sec;

	sec = 1000000;

	uart_init();
	nand_init();
	buzzer_init();

	nand_addr = LED_NAND_ADDR;		//16K
	sdram_addr = LED_DRAM_ADDR;

	while(sec){
		buzzer_ring();
		delay(sec);
		buzzer_slient();
		delay(sec);
		if(sec >= 100000)
			sec -= 100000;
		else
			sec -= 5;
	}
	if(*(int *)0xE2900010 & 0x1){
		nand_read((char *)sdram_addr, nand_addr, LED_NAND_SIZE);
		go(sdram_addr);
	}
	else
		help();
		//load_shell();



	return 0;
}

//void load_shell(void)
//{
//char buf[BUFSIZE];
//char cmd[CMDSIZE];
//char parm[PARMNUM][PARMLEN];
//while(1){
//uart_puts("shell$");
//uart_gets_cmd(buf, cmd);
//switch(){
//case "help":
//help();
//break;
////case "go":
////go(parm[0]);
//	
//}
//}
//////////////////////}
