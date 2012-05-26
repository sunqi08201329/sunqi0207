#include "package.h"

int main(int argc, const char *argv[])
{
	union{
		short s;
		char c[sizeof(short)];
	}un;

	un.s = 0x0102;
	printf("%s:", "asdasd");
	if(sizeof(short) == 2){
		if((un.c[0] == 1) && (un.c[1] == 2))
			printf("big-endian\n");
		else if((un.c[0] == 2) && (un.c[1] == 1))
			printf("little-endian\n");
		else
			printf("unknow\n");
	}
	printf("sizeof(short) = %d\n", (int)sizeof(short));
	return 0;
}
