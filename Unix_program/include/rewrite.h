#ifndef __REWIRITE__H__
#define  __REWIRITE__H__

#include <stdio.h>

ssize_t readn(int fd, void *vptr, size_t n);
ssize_t writen(int fd, void *vptr, size_t n);
ssize_t readline(int fd, void *vptr, size_t maxlen);

#endif  //__REWIRITE__H__
