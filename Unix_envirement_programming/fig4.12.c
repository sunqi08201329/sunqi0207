#include <stdio.h>

int main(int argc, const char *argv[])
{
	struct stat statbuf;

	stat_r("Makefile", &statbuf);
	chmod_r("Makefile", mode);
	chmod_r("Makefile", mode);
	return 0;
}
