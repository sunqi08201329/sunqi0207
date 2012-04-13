#include "apue.h"

int main(int argc, const char *argv[])
{
	char c;
	//int getc(FILE *stream);
	while((c = getc(stdin)) != EOF){
		putc(c, stdout);
	}
	ferror
	return 0;
}
