#include "apue.h"
#include "socket.h"
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>

//#define MAXLINE 1024
#define SERVER_PORT 8000

int main(int argc, const char *argv[])
{
	struct sockaddr_in server_addr;
	char buf[MAXLINE];
	int n, sock_fd;

	if(argc != 2)
		err_sys("Usage ./server server_addr msg");
	//int socket_r(int domain, int type, int protocol);
	sock_fd = socket_r(AF_INET, SOCK_STREAM, 0);

	memset(&server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	//int inet_pton(int af, const char *src, void *dst);
	inet_pton(AF_INET, argv[1], &server_addr.sin_addr);
	server_addr.sin_port = htons(SERVER_PORT);
	//void connect_r(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen, void *arg);
	connect_r(sock_fd, (struct sockaddr *)&server_addr, sizeof(server_addr), (void *)argv[1]);
	//ssize_t write_r(int fd, const void *ptr, size_t nbytes);
	fprintf(stdout, "\n");
	while(fgets(buf, MAXLINE, stdin) != NULL){

		if(write_r(sock_fd, buf, strlen(buf)) == -1)
			err_ret("write_r error");
		//supplemention
		//ssize_t read_r(int fd, void *ptr, size_t nbytes);
		n = read(sock_fd, buf, MAXLINE);
		if(n == 0)
			fprintf(stdout, "peer side(%s port %d) has been closed.\n", argv[1], ntohs(server_addr.sin_port));
		else {

			fprintf(stdout, "responsed from server:\n");
			write_r(STDOUT_FILENO, buf, n);
			//fprintf(stdout, "\n");
		}
	}
	//void close_r(int fd);
	close_r(sock_fd);
	return 0;
}
