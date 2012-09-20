#include "package.h"
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <arpa/inet.h>
#include <netinet/in.h>

int main(int argc, const char *argv[])
{
	int socket, listen_sock;
	pid_t child_pid;
	socklen_t  client_addr_len;
	struct sockaddr_in server_addr, client_addr;
	time_t ticks;
	char buff[MAXLINE];
	//int socket_r(int domain, int type, int protocol);
	//socket
	listen_sock = socket_r(AF_INET, SOCK_STREAM, 0);
	bzero(&server_addr, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	server_addr.sin_port = htons(80);
	//inet_pton_r(AF_INET, argv[1], &server_addr.sin_addr);
	//bind
	//void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, void *arg);
	bind_r(listen_sock, (struct sockaddr *)&server_addr, sizeof(server_addr), &argv[1]);
	
	//listen
	//void listen_r(int sockfd, int backlog, void *arg);
	listen_r(listen_sock, 10, &argv[1]);
	//accept
	//int accept_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
	while(1){
		socket = accept_r(listen_sock, (struct sockaddr *)&client_addr, &client_addr_len);
		//const char *inet_ntop_r(int af, const void *src, char *dst, socklen_t cnt);
		printf("connection ftom %s, port %d\n", inet_ntop_r(AF_INET, &client_addr.sin_addr, buff, sizeof(buff)), ntohs(client_addr.sin_port));
		if((child_pid = fork_r()) == 0){
			close_r(listen_sock);
			ticks = time(NULL);
			snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
			//write
			//ssize_t write_r(int fd, const void *ptr, size_t nbytes);
			write_r(socket, buff, strlen(buff));
			exit(0);
		}
		sleep(1);
		close_r(socket);
	}
	return 0;
}
