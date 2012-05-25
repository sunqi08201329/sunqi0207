#include <stdio.h>
#include <errno.h>

int main(int argc, const char *argv[])
{
	fprintf(stderr, "EBADF:%s\n", strerror(EBADF));
	return 0;
}
