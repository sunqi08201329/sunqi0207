#include <stdio.h>
#include <string.h>

void test2()
{
	char string[10], str1[10];
	int i;
	for(i=0; i<10; i++)
	{
		str1[i] = 'a';
	}
	strcpy(string, str1);
	printf("%s\n", string);
}

int main(int argc, const char *argv[])
{
	test2();
	return 0;
}
