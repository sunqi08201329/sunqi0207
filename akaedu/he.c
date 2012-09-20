#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>

int main(int argc, const char *argv[])
{
	int *p;
	int fd = open("hello", O_RDWR);
	if(fd < 0){
		perror("open hello");
		exit(1);
	}
	p = mmap(NULL, 6, PROT_WRITE, MAP_SHARED, fd, 0);
	if(p == MAP_FAILED){
		perror("map");
		exit(1);
	}
	close(fd);
	p[0] = 0x30313233;
	munmap(p, 6);
	
	return 0;
}
