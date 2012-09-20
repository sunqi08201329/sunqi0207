#include <stdio.h>
#include <string.h>
 void test1() 
{    
	char string[10];    
	char* str1="0123456789";    
	strcpy(string, str1);
	printf("%s\n", string);
	char *a = string;
	while(*a)
		a++;
} 

int main(int argc, const char *argv[])
{
	test1();
	return 0;
}
