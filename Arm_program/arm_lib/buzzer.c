#define GPD0CON (*(volatile unsigned int *)0xe02000a0)
#define GPD0DAT (*(volatile unsigned int *)0xe02000a4)

void buzzer_init(void)
{
	GPD0CON |= (1<<0);
}
void buzzer_ring(void)
{
	GPD0DAT = 0x1;
}
void buzzer_slient(void)
{
	GPD0DAT = 0x0;
}
