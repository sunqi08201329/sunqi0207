#ifndef _MEMORY_H_
#define _MEMORY_H_

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

static inline void *malloc_r(size_t size)
{
	void *ptr;

	ptr = malloc(size);
	if (ptr == NULL)
	{
		fprintf(stderr, "malloc failed: %s.\n", 
				strerror(errno));
		exit(EXIT_FAILURE);
	}
	return ptr;
}
#endif	//_MEMORY_H_
