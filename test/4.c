#include <stdio.h>
#include <string.h>

int main(int argc, const char *argv[])
{
	
	char a[10];
	scanf("%s", a);
	int len = strlen(a);
	char *p = a;
	char *q;
	q = &a[len - 1];
	int i = len/2;
	//printf("%c\n%c\n", *p, *q);
	while((*p++==*q--) && i--);
	//{
	//printf("%c\n%c\n", *p, *q);
	//}
	printf("%d\n", i);
	if(i){
		printf("shi\n");
		return 1;
	} else{
		printf("bu shi\n");
		return 0;
	}
}
