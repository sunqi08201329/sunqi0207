#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
void error(char *format, ...)
{
	va_list ap;
	va_start(ap, format);
	fprintf(stderr, "error: ");

	vfprintf(stderr, format, ap);
	va_end(ap);
	fprintf(stderr, "\n");
	exit(1);
}
int main(int argc, const char *argv[])
{
	error("%d,%s",1,"asd");
	return 0;
}
