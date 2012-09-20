#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>
#define BASE 0xE0100000

int main(int argc, const char *argv[])
{
	int fd;
	unsigned char * vmem;
	int i;
	fd = open("/dev/mem", O_RDWR);

	vmem = mmap(0, 0x1000, PROT_READ, MAP_SHARED, fd, BASE);
	i = 0;
	while (i < 0x1000){
		printf("(*(volatile unsigned int *)%x) = %x\n", BASE + i, *(vmem + i));
		i += 4;
	}
	munmap(vmem, 0x1000);
	close(fd);
	return 0;
}
