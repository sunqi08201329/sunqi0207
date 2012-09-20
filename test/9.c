#include <stdio.h>
#define f1(n) (n)*(n)

int main(int argc, const char *argv[])
{
	int i=5;
	int k=0;
	k=f1(i++);
	printf("%d %d",i,k);

	return 0;
}
