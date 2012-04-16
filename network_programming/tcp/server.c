#include "apue.h"
#include "socket.h"
#include <sys/wait.h>
#include <netinet/in.h>
#include <signal.h>
#include <arpa/inet.h>
#include <errno.h>
#include <ctype.h>

//#define MAXLINE 1024
#define SERVER_PORT 8000
#define SERVER_BACKLOG 10

void signal_handler(int signo);

int main(int argc, const char *argv[])
{
	
	struct sockaddr_in server_addr, client_addr;
	socklen_t client_addr_len;
	int connection_sock, listen_sock;
	char buf[MAXLINE];
	char str[INET_ADDRSTRLEN];
	int i,n;
	char bindmsg[1024];

	int optval = 1;

	//struct sigaction {
	//void     (*sa_handler)(int);
	//void     (*sa_sigaction)(int, siginfo_t *, void *);
	//sigset_t   sa_mask;
	//int        sa_flags;
	//void     (*sa_restorer)(void);
	//};
	struct sigaction act, oact;

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

	//int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact)

//siganl process
	act.sa_flags = 0;
	act.sa_handler = signal_handler;
	sigemptyset(&act.sa_mask);

	sigaction(SIGCHLD, &act, &oact);

	fprintf(stdout, "accepting connections ...\n");
	
	pid_t pid;
	while(1){
		client_addr_len = sizeof(client_addr);
		//int accept_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
		connection_sock = accept_r(listen_sock, (struct sockaddr *)&client_addr, &client_addr_len);
		if(connection_sock < 0){
			if(errno == EINTR)
				continue;
			err_ret("accept() failed");
		}

		pid = fork();
		if(pid < 0)
			err_sys("call to fork");
		else if(pid == 0){
			close_r(listen_sock);
		//ssize_t read_r(int fd, void *ptr, size_t nbytes);
			while(1){
				n = read_r(connection_sock, buf, MAXLINE);
				if(n == 0) {
					fprintf(stdout, "peer side(%s port %d) has been closed.\n", inet_ntop(AF_INET, &client_addr.sin_addr, str, sizeof(str)), ntohs(client_addr.sin_port));
					break;
				}

				fprintf(stdout, "reciveed from %s at port %d\n", inet_ntop(AF_INET, &client_addr.sin_addr, str, sizeof(str)), ntohs(client_addr.sin_port));
				for (i = 0; i < n; i++) 
				{
					buf[i] = toupper(buf[i]);
				}
				//ssize_t write_r(int fd, const void *ptr, size_t nbytes);
				write_r(connection_sock, buf, n);
			}
			close_r(connection_sock);	
			exit(0);
		} else {
			close_r(connection_sock);	
		}
			//void close_r(int fd);
			//close_r(connection_sock);
	}
	return 0;
}
void signal_handler(int signo)
{
	pid_t pid;
	int status;
	while((pid = waitpid(-1, &status, WNOHANG)) > 0)
		fprintf(stdout, "child %d terminated\n", pid);
	return;
}
