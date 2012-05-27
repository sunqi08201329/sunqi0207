#include "rewrite.h"
#include <errno.h>

ssize_t readline(int fd, void *vptr, size_t maxlen)
{
	size_t n, rc;
	char *ptr, c;

	ptr = vptr;

	for (n = 0; n < maxlen; n++) {
again:
		if((rc = read(fd, &c, 1)) == 1){
			*ptr++ = c;
			if(c == '\n')
				break;
		} else if(rc == 0){
			*ptr = 0;
			return n - 1;
		} else {
			if(errno == EINTR)
				goto again;
		return -1;
		}
	}

	*ptr = 0;

	return n;
}
