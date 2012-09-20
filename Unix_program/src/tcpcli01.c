#include "package.h"
#include "rewrite.h"
#include <netinet/in.h>


void str_cli(FILE *fp, int sockfd);

int main(int argc, const char *argv[])
{
	int sockfd;
	struct sockaddr_in servaddr;

	if(argc != 2)
		err_quit("usage: tcpcli <ipaddr>");
	sockfd = socket_r(AF_INET, SOCK_STREAM, 0);

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htonl(80);
	inet_pton_r(AF_INET, argv[1], &servaddr.sin_addr);
	connect_r(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr), (char *)argv[1]);
	str_cli(stdin, sockfd);
	exit(0);
	return 0;
}

void str_cli(FILE *fp, int sockfd)
{
	char sendlen[MAXLINE], recvline[MAXLINE];
	while(fgets_r(sendlen, MAXLINE, fp) != NULL){
		writen(sockfd, sendlen, strlen(sendlen));
		if(read_r(sockfd, recvline, MAXLINE) == 0)
			err_quit("str_cli:server terminated prematurely");
		fputs_r(recvline, stdout);
	}
}
