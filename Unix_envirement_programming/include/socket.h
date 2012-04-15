#ifndef __SOCKET__H__
#define  __SOCKET__H__

#include "apue.h"
#include <sys/socket.h>
int socket_r(int domain, int type, int protocol);
void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, void *arg);
void listen_r(int sockfd, int backlog, void *arg);
void connect_r(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen, void *arg);
int accept_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
ssize_t send_r(int new_connected_socket, const void *buf, size_t len, int flags);
ssize_t recv_r(int new_connected_socket, void *buf, size_t len, int flags);
void close_r(int fd);
ssize_t read_r(int fd, void *ptr, size_t nbytes);
ssize_t write_r(int fd, const void *ptr, size_t nbytes);

#endif // __SOCKET__H__
