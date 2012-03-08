#include <stdio.h>
#include "head.h"

int main(int argc, const char *argv[])
{
	fprintf(stdout, "Hello World!\n");
	fprintf(stdout, "add:%d\n", add(1, 3));
	fprintf(stdout, "mul:%d\n", mul(1, 3));
	return  0;
}
