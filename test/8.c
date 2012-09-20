#include <stdio.h>
#include <string.h>

void len(char *arr)
{
	printf("%d\n", (int)strlen(arr));
}

int main(int argc, const char *argv[])
{
	char a[10] = "asd";
	len(a);
	return 0;
}
