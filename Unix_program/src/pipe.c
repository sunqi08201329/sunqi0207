#include "package.h"

#define MAXLEN 1024

void client(int, int), server(int, int);

int main(int argc, const char *argv[])
{
	int pipe1[2], pipe2[2];
	pid_t childpid;
	
	//void pipe_r(int *fds);
	pipe_r(pipe1);
	pipe_r(pipe2);
	//pid_t fork_r(void);
	if((childpid = fork_r()) == 0){
		close_r(pipe1[1]);
		close_r(pipe2[0]);
		server(pipe1[0], pipe2[1]);
		exit(0);
	}
	close_r(pipe2[1]);
	close_r(pipe1[0]);
	client(pipe2[0], pipe1[1]);
	//pid_t waitpid_r(pid_t pid, int *iptr, int options);
	waitpid_r(childpid, NULL, 0);
	exit(0);
}

void client(int readfd, int writefd)
{
	size_t len;
	int n;
	char buff[MAXLEN];
	//char *fgets_r(char *s, int size, FILE *stream);
	fgets_r(buff, MAXLEN, stdin);
	len = strlen(buff);
	if(buff[len - 1] == '\n')
		len--;
	//ssize_t write_r(int fd, const void *ptr, size_t nbytes);
	write_r(writefd, buff, len);
	//ssize_t read_r(int fd, void *ptr, size_t nbytes);
	while((n = read_r(readfd, buff, MAXLEN)) > 0)
		write_r(STDOUT_FILENO, buff, n);
}

void server(int readfd, int writefd)
{
	int n;
	int fd;
	char buff[MAXLEN];
	n = read_r(readfd, buff, MAXLEN);
	buff[n] = '\0';
	//int open_r(const char *pathname, int oflag, mode_t mode);
	if((fd = open_r(buff, O_RDONLY, 0644)) < 0){
		//int snprintf(char *str, size_t size, const char *format, ...);
		snprintf(buff + n, sizeof(buff) - n, ": can't open, %s\n", strerror(errno));
		n = strlen(buff);
		write_r(writefd, buff, n);
	} else {
		while( (n = read_r(fd, buff, MAXLEN)) > 0){
			write_r(writefd, buff, n);
		}
	}
	close_r(fd);
}
