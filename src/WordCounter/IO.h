#ifndef _IO_H_
#define _IO_H_

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

static inline FILE *fopen_r(const char *path, const char *mode)
{
	FILE *fp;

	fp = fopen(path, mode);
	if (fp == NULL)
	{
		fprintf(stderr, "Open file %s failed: %s.\n", path,
				strerror(errno));
		exit(EXIT_FAILURE);
	}

	return fp;
}

static inline int fclose_r(FILE *fp)
{
	if (fclose(fp) == EOF)
	{
		fprintf(stderr, "close file:%p failed: %s.\n", fp,
				strerror(errno));
		exit(EXIT_FAILURE);
	}
	return 0;
}
#endif	//_IO_H_
