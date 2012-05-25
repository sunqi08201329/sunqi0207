#include "apue.h"
#include <errno.h>
int main(int argc, const char *argv[])
{
	fprintf(stderr, "EACCESS %s\n", strerror(EACCES));
	errno = ENOENT;
	perror(argv[1]);
	return 0;
}
