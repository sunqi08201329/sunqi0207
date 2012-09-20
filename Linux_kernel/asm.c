#include <stdio.h>

int main(int argc, const char *argv[])
{
	int a1 = 10, b1 = 0;
	asm("movl %1, %eax;\n\t"
		"movl %eax, %ecx;"
		:"=a"(b1)
		:"b"(a1)
		:"%eax");
	printf("Result : %d, %d\n", a1, b1);
	return 0;
}
