#include "package.h"
#include <netinet/in.h>
#include <stdio.h>
void str_echo(int sockfd);

int main(int argc, const char *argv[])
{
	int listenfd, connfd;
	pid_t childpid;
	socklen_t clilen;
	struct sockaddr_in cliaddr, servaddr;
	listenfd = socket_r(AF_INET, SOCK_STREAM, 0);
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(argv[1]);
	servaddr.sin_port = htons(80);
	//void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, void *arg);
	bind_r(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr), (char *)argv[1]);
	//void listen_r(int sockfd, int backlog, void *arg);
	listen_r(listenfd, 10, (char *)argv[1]);
	for(;;){
		clilen = sizeof(cliaddr);
		//int accept_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
		connfd = accept_r(listenfd, (struct sockaddr *)&cliaddr, &clilen);	
		if((childpid = fork_r()) == 0){
			close_r(listenfd);
			str_echo(connfd);
			exit(0);
		}
	}
	close_r(connfd);
	return 0;
}

void str_echo(int sockfd)
{
	ssize_t n;
	char buf[MAXLINE];
again:
	while((n = read(sockfd, buf, MAXLINE)) > 0)
		write(sockfd, buf, n);
	if(n < 0 && errno == EINTR)
		goto again;
	else if(n < 0)
		err_sys("str_echo: read error");
}
