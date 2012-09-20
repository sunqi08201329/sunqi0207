#include <stdio.h>

int main(int argc, const char *argv[])
{
	int countx = 0; 
	int x;
	scanf("%d", &x);

	while ( x ) 
	{ 
		countx ++; 
		x = x&(x-1); 
	} 
	printf("%d\n", countx); 

	return 0;
}
