#include "apue.h"
#include <sys/socket.h>
//int socket(int domain, int type, int protocol);
int socket_r(int domain, int type, int protocol)
{
	int listening_socket;
	if ((listening_socket = socket(domain, type, protocol)) < 0)
		err_sys("Create new  %d socket failed", domain);
	fprintf(stdout, "Created a new UNIX domain socket, listening_socket = %d\n", listening_socket);
	return listening_socket;
}
//int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, unsigned short port)
{		 
	if (bind(listening_socket, addr, addrlen) < 0){
		close(listening_socket);
		err_sys("Bind to %u failed", port);
	}
	fprintf(stdout, "Bound to %u successfully.\n", port);
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
int connect_r(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen, void *arg)
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
	if ((n = send(new_connected_socket, buf, len, flags)) < 0){ // failed
		err_ret("Send data to client failed");
	}else { // success
		fprintf(stdout, "Sent %d bytes to client.\n", n);
	}
	return n;
}
// ssize_t recv(int s, void *buf, size_t len, int flags);
ssize_t recv_r(int new_connected_socket, void *buf, size_t len, int flags)
{
	ssize_t n;
	if ((n = recv(new_connected_socket, buf, sizeof(buf) - 1, 0)) < 0)
		// failed
		err_ret("Receive data on socket %d failed", new_connected_socket);
	else if (n == 0)
		// Connetion closed by peer.
		fprintf(stdout, "Connection closed by peer.\n");
	else
		// success
		fprintf(stdout, "Received %d bytes from client, echo back.\n", n);
	return n;
}
