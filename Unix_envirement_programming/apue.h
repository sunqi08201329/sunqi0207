#ifndef _APUE_H_
#define _APUE_H_
#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>

static inline void stat_r(const char *restrict pathname, struct stat *restrict buf)
{
	if(stat(pathname, buf) < 0){
		fprintf(stderr, "stat error(%s) for %s\n", strerror(errorno), pathname);
		exit(1);
	}
}
static inline void chmod_r(const char * pathname, mode_t mode)
{
	if(stat(pathname, mode) < 0){
		fprintf(stderr, "chmod error(%s) for %s\n", strerror(errorno), pathname);
		exit(1);
	}
}

#endif //_APUE_H_
