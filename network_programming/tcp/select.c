#include "apue.h"
#include "socket.h"
#include <netinet/in.h>
#include <sys/select.h>
#include <arpa/inet.h>
#include <errno.h>
#include <ctype.h>

//#define MAXLINE 1024
#define SERVER_PORT 8000
#define SERVER_BACKLOG 10

int main(int argc, const char *argv[])
{

	fd_set rset, allset;
	struct sockaddr_in server_addr, client_addr;
	int nready, client[FD_SETSIZE];
	socklen_t client_addr_len;
	int connection_sock, listen_sock, maxi, maxfd, sockfd;
	char buf[MAXLINE];
	char str[INET_ADDRSTRLEN];
	int i, n;
	char bindmsg[1024];
	int optval = 1;

	//void *memcpy(void *dest, const void *src, size_t n);
	strcpy(bindmsg, argv[1]);
	strcat(bindmsg, " prot 8000");
	if(argc != 2)
		err_sys("Usage ./server server_addr");
	//int socket_r(int domain, int type, int protocol);
	listen_sock = socket(AF_INET, SOCK_STREAM, 0);

	//int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
	setsockopt_r(listen_sock, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));

	memset(&server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(SERVER_PORT);
	//int inet_pton(int af, const char *src, void *dst);
	inet_pton(AF_INET, argv[1], &server_addr.sin_addr);
	//void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, void *arg);
	bind_r(listen_sock, (struct sockaddr *)&server_addr, sizeof(server_addr), (void *)bindmsg);
	//void listen_r(int sockfd, int backlog, void *arg);
	listen_r(listen_sock, SERVER_BACKLOG, (void *)bindmsg);

	maxfd = listen_sock;
	maxi = -1;
	for (i = 0; i < FD_SETSIZE; i++) 
	{
		client[i] = -1;	
	}
	FD_ZERO(&allset);
	FD_SET(listen_sock, &allset);

	while(1){
		rset = allset;
		//int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
		nready = select(maxfd + 1, &rset, NULL, NULL, NULL);
		if(nready < 0)
			err_sys("select error");
		if(FD_ISSET(listen_sock, &rset)){	
			client_addr_len = sizeof(client_addr);
			connection_sock = accept_r(listen_sock, (struct sockaddr *)&client_addr, &client_addr_len);
			fprintf(stdout, "reciveed from %s at port %d\n", inet_ntop(AF_INET, &client_addr.sin_addr, str, sizeof(str)), ntohs(client_addr.sin_port));
			for (i = 0; i < FD_SETSIZE; i++) 
			{
				if(client[i] < 0){
					client[i] = connection_sock;
					break;
				}
			}
			if(i == FD_SETSIZE){
				fprintf(stderr, "too many clients\n");
				exit(1);
			}
			FD_SET(connection_sock, &allset);

			if(connection_sock > maxfd)
				maxfd = connection_sock;
			if(i > maxi)
				maxi = i;
			if(--nready == 0)
				continue;
		}
		for (i = 0; i < maxi; i++) 
		{
			if((sockfd = client[i]) < 0)
				continue;
			if(FD_ISSET(sockfd, &rset)){
				if((n = read_r(connection_sock, buf, MAXLINE)) == 0){
					close_r(sockfd);	
					FD_CLR(sockfd, &allset);
					fprintf(stdout, "peer side(%s port %d) has been closed.\n", inet_ntop(AF_INET, &client_addr.sin_addr, str, sizeof(str)), ntohs(client_addr.sin_port));
					client[i] = -1;
				} else {
					int j;
					for (j = 0; j < n; j++) 
					{
						buf[j] = toupper(buf[j]);
					}
					write_r(connection_sock, buf, n);
				}
				if(--nready == 0)
					break;
			}
		}
	}
	return 0;
}
