
#define GPJ2CON *((volatile unsigned int *)0XE0200280)
#define GPJ2DAT *((volatile unsigned int *)0XE0200284)


void led_init(void)
{
	GPJ2CON = 0X1111;
	GPJ2DAT = 0XF;
}

void led_on(int num)
{
	GPJ2DAT &= ~(1<<num);
}

void led_off(int num)
{
	GPJ2DAT |= (1<<num);
}
