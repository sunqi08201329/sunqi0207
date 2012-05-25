#include <stdio.h>

char *func(char *a)
{
	char *b;
	a[3] = '\0';
	b = a;
	return b;
}
int main(int argc, const char *argv[])
{
	char a[12] = "asdasd";
	char *b = func(a);	
	printf("%s\n", b);
	return 0;
}
