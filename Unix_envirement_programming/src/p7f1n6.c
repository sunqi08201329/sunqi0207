#include "apue.h"
#include <sys/wait.h>
int main(int argc, const char *argv[])
{
	char buf[MAXLINE];
	int pid;
	int status;
	printf("%%");
	while(fgets(buf, sizeof(buf), stdin) != NULL){
		if(buf[strlen(buf) - 1] == '\n')
			buf[strlen(buf) - 1] = 0;
		if((pid = fork()) < 0)
			err_sys("fork error");
		else if(pid == 0){
			//int execlp(const char *file, const char *arg, ...);
			execlp(buf, buf, (char *)0);
			err_ret("execute %s error", buf);
			exit(127);
		}
		//pid_t waitpid(pid_t pid, int *status, int options);
		if((pid = waitpid(pid, &status, WNOHANG)) < 0)	
			err_sys("waitpid eror");
		printf("%%");
			
	}
	return 0;
}
