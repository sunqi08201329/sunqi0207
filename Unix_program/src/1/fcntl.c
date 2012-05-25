#include "apue.h"
#include <fcntl.h>

int main(int argc, const char *argv[])
{
	
	int total_fd;
	if(argc != 2)
		err_sys("Usage ./fcntl fd");
	//int fcntl(int fd, int cmd, ... /* arg */ );
	//cmd: F_DUPFD (long) F_GETFD (void) F_SETFD (long) F_GETFL (void) F_SETFL (long)
	if((total_fd = fcntl(strtol(argv[2], NULL, 10), F_GETFL, 0)) < 0)
		err_sys("fcntl() error");
	//fcntl(strtol(argv[1], NULL, 10), F_SETFL, total_fd | O_APPEND);
	//if((total_fd = fcntl(strtol(argv[2], NULL, 10), F_SETFL, total_fd | O_APPEND)) < 0)
	//err_sys("fcntl() error");
	//if((total_fd = fcntl(strtol(argv[2], NULL, 10), F_GETFL, 0)) < 0)
	//err_sys("fcntl() error");
	//fprintf(stdout, "flags: %x\n", 
	switch(total_fd & O_ACCMODE){ //O_ACCMODE 00000003
		case O_RDONLY: 
			fprintf(stdout, "read only");
			break;
		case O_WRONLY:
			fprintf(stdout, "write only");
			break;
		case O_RDWR:
			fprintf(stdout, "write and read");
			break;
		default:
			err_dump("unknow access mode");
	}
	if(total_fd & O_APPEND)
		fprintf(stdout, ", append");
	if(total_fd & O_NONBLOCK)
		fprintf(stdout, ", nonblock");
	fprintf(stdout, "\n");
			
	return 0;
}
