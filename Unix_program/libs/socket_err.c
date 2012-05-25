#include "package.h"
#include <errno.h>

//int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
int accept_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
{
	int n;
again:
	if((n = accept(sockfd, addr, addrlen)) < 0){
		if ((errno == ECONNABORTED) || (errno == EINTR))
			goto again;
		else
			err_sys("accept %d error", sockfd);
	}
	return n;
}
//int socket(int domain, int type, int protocol);
int socket_r(int domain, int type, int protocol)
{
	int listening_socket;
	if ((listening_socket = socket(domain, type, protocol)) < 0)
		err_sys("Create new  %d socket failed", domain);
	fprintf(stdout, "Created a new socket, listening_socket = %d\n", listening_socket);
	return listening_socket;
}
//int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, void * arg)
{		 
	if (bind(listening_socket, addr, addrlen) < 0){
		close(listening_socket);
		err_sys("Bind to %s failed", (char *)arg);
	}
	fprintf(stdout, "Bound to %s successfully.\n", (char *)arg);
}
// int listen(int sockfd, int backlog);
void listen_r(int sockfd, int backlog, void *arg)
{
	if (listen(sockfd, backlog) < 0)
	{
		close(sockfd);
		err_sys("Listen on %s failed", (char *)arg);
	}

	fprintf(stdout, "Listen on %s successfully.\n", (char *)arg);
}
//int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen);
void connect_r(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen, void *arg)
{
	if (connect(sockfd, serv_addr, addrlen) < 0)
	{
		// FIXME: retry some times?
		close(sockfd);
		err_sys("Connect to remote server %s failed", (char *)arg);
	}
	fprintf(stdout, "Connected to remote server %s", (char *)arg);
}
// ssize_t send(int s, const void *buf, size_t len, int flags);
ssize_t send_r(int new_connected_socket, const void *buf, size_t len, int flags)
{
	ssize_t n;
again:
	if ((n = send(new_connected_socket, buf, len, flags)) < 0){ // failed
		goto again;
		err_ret("Send() error");
		return -1;
	}
	return n;
}
// ssize_t recv(int s, void *buf, size_t len, int flags);
ssize_t recv_r(int new_connected_socket, void *buf, size_t len, int flags)
{
	ssize_t n;
again:
	if ((n = recv(new_connected_socket, buf, sizeof(buf) - 1, 0)) < 0){
		// failed
		goto again;
		err_ret("Receive data on socket %d failed", new_connected_socket);
		return -1;
	}
	return n;
}
void close_r(int fd)
{
	if(close(fd) == -1)
		err_sys("close error fd %d", fd);
}
ssize_t read_r(int fd, void *ptr, size_t nbytes)
{
	ssize_t n;
again:
	if(( n = read(fd, ptr, nbytes)) < 0){
		if(errno = EINTR)
			goto again;
		else {
			err_ret("read() error");
			return -1;
		}
	}
	return n;
}
ssize_t write_r(int fd, const void *ptr, size_t nbytes)
{
	ssize_t n;
again:
	if(( n = write(fd, ptr, nbytes)) < 0){
		if(errno = EINTR)
			goto again;
		else {
			err_ret("write() error");
			return -1;
		}
	}
	return n;
}
int getsockopt_r(int sockfd, int level, int optname, void *optval, socklen_t *optlen)
{
	if(getsockopt(sockfd, level, optname, optval, optlen) == -1)
		err_ret("getsockopt() error");
}
int setsockopt_r(int sockfd, int level, int optname, const void *optval, socklen_t optlen)
{
	if(setsockopt(sockfd, level, optname, optval, optlen) == -1)
		err_ret("setsockopt() error");
}
