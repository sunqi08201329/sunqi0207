#include "package.h"
#include <string.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdlib.h>


int main(int argc, const char *argv[])
{
	int sockfd, n;
	struct sockaddr_in server_addr;
	char recvline[MAXLINE];
	//socket
	//int socket_r(int domain, int type, int protocol);
	sockfd = socket_r(AF_INET, SOCK_STREAM, 0);
	//bzero
	//void bzero(void *s, size_t n);
	bzero(&server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(80);
	//inet_pton
	//int inet_pton_r(int af, const char *src, void *dst);
	inet_pton_r(AF_INET, argv[1], &server_addr.sin_addr);
	//connect
	//void connect_r(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen, void *arg);
	connect_r(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr), argv[1]);
	//read
	//ssize_t read_r(int fd, void *ptr, size_t nbytes);
	while((n = read_r(sockfd, recvline, MAXLINE)) > 0){
		recvline[n] = 0;
		if(fputs(recvline, stdout) == EOF)
			err_sys("fputs error");
	}

	if(n < 0)
		err_sys("read error");
	//write
	//ssize_t write_r(int fd, const void *ptr, size_t nbytes);
	return 0;
}
