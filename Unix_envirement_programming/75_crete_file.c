#include <stdio.h>

int main(int argc, const char *argv[])
{
	int fd;
	if((fd = open("1.c", O_WRONLY)) < 0){
		if(error == ENOENT){
			if((fd = creat("1.c", mode))<0)
				err_sys("creat error");
		}else{
			err_sys("open error");
		}
	}
	return 0;
}
