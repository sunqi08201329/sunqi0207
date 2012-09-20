#include "package.h"

//-----------------------------------------------------------------------------------------
//	standard library function error process
//-----------------------------------------------------------------------------------------
FILE *fopen_r(const char *path, const char *mode)
{
	FILE *fp;
	if((fp = fopen(path, mode)) == NULL)
		err_sys("fopen(%s, %s) error", path, mode);
	return fp;
}
//takes an existing file descriptor, which we could obtain from the 
//open, dup, dup2, fcntl, pipe, socket, socketpair, or accept functions
FILE *fdopen_r(int fd, const char *mode)
{
	FILE *fp;
	if((fp = fdopen(fd, mode)) == NULL)
		err_sys("fdopen(%d, %s) error", fd, mode);
	return fp;
}
//The  original stream (if it exists) is closed.
FILE *freopen_r(const char *path, const char *mode, FILE *stream)
{
	FILE *fp;
	if((fp = freopen(path, mode, stream)) == NULL)
		err_sys("freopen(%s, %s, stream) error", path, mode);
	return fp;
}
int fclose_r(FILE *fp)
{
	int i;
	if((i = fclose(fp)) == EOF)
		err_ret("fclose error");
}
char *fgets_r(char *s, int size, FILE *stream)
{
	char *ptr;
	if((ptr = fgets(s, size, stream)) == NULL && ferror(stream))
		err_sys("fgets error");
	return ptr;
}
void fputs_r(const char *buf, FILE *stream)
{
	if(fputs(buf, stream) == EOF)
		err_sys("fputs error");
}
