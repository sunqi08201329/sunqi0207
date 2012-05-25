#include "apue.h"
#include "file_err.h"

int main(int argc, const char *argv[])
{
	
	struct stat file_stat;
	stat_r(argv[1], &file_stat);
	//int chmod(const char *path, mode_t mode);
	//chmod_r(argv[1], (file_stat.st_mode & ~S_IXGRP) | S_ISGID);
	//int fchmod(int fd, mode_t mode);
	chmod_r(argv[1], (file_stat.st_mode & ~S_IXUSR));
	return 0;
}
