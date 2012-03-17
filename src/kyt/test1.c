#include <stdio.h>

int main(int argc, const char *argv[])
{
	char a[10] = "123";
	char b[10] = "456";
	char c[20];
	sprintf(c,"%s",a);
	sprintf(c,"%s",b);
	printf("%s\n",c);
	return 0;
}
