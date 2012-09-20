
#include <stdio.h>
#define SQUARE(a)  ((a)*(a))   

int main(int argc, const char *argv[])
{
	int a=5;    
	int b;    
	b=SQUARE(a++); 
	
	printf("%d\n%d\n", a, b);
	return 0;
}

