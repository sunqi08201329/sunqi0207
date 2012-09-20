#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char *argv[])
{
	int i;
	//int x=0x12345678;
	int *x = malloc(sizeof(int));
	*x = 0x12345678;
	unsigned char *p=(unsigned char *)x;
	printf("%d\n", sizeof(x));
	for(i=0;i<sizeof(*x);i++)
		printf("%2x",*(p+i));

	return 0;
}
