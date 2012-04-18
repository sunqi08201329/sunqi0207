#include "apue.h"
#include "file_err.h"
#include <unistd.h>

int main(int argc, const char *argv[])
{
	//int access(const char *pathname, int mode);
	access_r(argv[1], R_OK);
	fprintf(stdout, "%s can read\n", argv[1]);
	return 0;
}
