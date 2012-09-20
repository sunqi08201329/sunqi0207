#include <stdio.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>

#define MAXLINE 80

int main(int argc, const char *argv[])
{
	int n;
	int fd[2];
	char line[MAXLINE];
	pid_t pid;
	if(pipe(fd) < 0){
		perror("pipe");
		exit(EXIT_FAILURE);
	} 
	if((pid = fork()) < 0){
		perror("fork");
		exit(EXIT_FAILURE);
	} else if(pid > 0){
		close(fd[0]);
			write(fd[1], "hello world\n", 12);
			wait(NULL);
	} else {
		close(fd[1]);
			n = read(fd[0], line, MAXLINE);
			write(STDOUT_FILENO, line, n);
	}
	return 0;
}
