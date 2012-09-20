#include <stdio.h>

int main(int argc, const char *argv[])
{
	int a = 4;
	int b = 4;
	int c = 4;
	int d = 4;
	a += (a++);
	b +=(++b);
	(c++)+=c;
	(++d)+=(d++);
	printf("a=%d\nb=%d\nc=%d\nd=%d\n", a, b, c, d);
	printf("%d\n%d\n", a, b);
	return 0;
}
