#include "apue.h"
void stat_r(const char * pathname, struct stat *buf)
{
	if(stat(pathname, buf) < 0){
		fprintf(stderr, "stat error(%s) for %s\n", strerror(errno), pathname);
		exit(1);
	}
}
void chmod_r(const char * pathname, mode_t mode)
{
	if(chmod(pathname, mode) < 0){
		fprintf(stderr, "chmod error(%s) for %s\n", strerror(errno), pathname);
		exit(1);
	}
}
int open_r(const char * pathname, int flags)
{
	int fd;
	if((fd = open(pathname, flags)) < 0){
		fprintf(stderr, "open error(%s) for %s\n", strerror(errno), pathname);
		exit(1);
	}

	return fd;
}
int write_r(int filedes, char *data, size_t bytes)
{
	int write_num;
	if((write_num = write(filedes, data, bytes)) < 0){
		fprintf(stderr, "write error(%s) for %d\n", strerror(errno), filedes);
		return write_num;
	}
	return write_num;
		
}
int read_r(int filedes, char *data, size_t bytes)
{
	int read_num;
	if((read_num = read(filedes, data, bytes)) < 0){
		fprintf(stderr, "read error(%s) for %d\n", strerror(errno), filedes);
		return read_num;
	}
	return read_num;
}
