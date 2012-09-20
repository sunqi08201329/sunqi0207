#include <stdio.h>

int main(int argc, const char *argv[])
{
	int a = 1,b;
	b = a++ + a++;
	printf("a=%d\nb=%d\n", a, b);
	return 0;
}
