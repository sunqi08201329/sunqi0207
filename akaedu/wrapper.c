#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

int main(int argc, const char *argv[])
{
	int fd;
	if(argc != 2){
		fputs("usage: wrapper file\n", stderr);
		exit(EXIT_FAILURE);
	}
	fd = open(argv[1], O_RDONLY);
	if(fd < 0){
		perror("open");
		exit(EXIT_FAILURE);
	}
	dup2(fd, STDIN_FILENO);
	close(fd);
	execl("./upper", "upper", NULL);
	perror("./exec ./upper");
	exit(1);
	return 0;
}
