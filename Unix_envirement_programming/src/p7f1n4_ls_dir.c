#include "apue.h"
#include <dirent.h>

#define BUFF_SIZE 4096
	
int main (int argc, const char *argv[])
{
	DIR *dp;
	struct dirent *dirp;
	char pathname[BUFF_SIZE];
	int n;

	//if (argc != 2)
	//{
	//err_quit ("usage: ls directory_name");
	//}
	//DIR *opendnr(const char *name);
	//return a pointer to the directory stream. 
	//On error, NULL isreturned,  and errno is set appropriately.
	while((n = read(STDIN_FILENO, pathname, sizeof(pathname)) > 0)){
		pathname[strlen(pathname) - 1] = '\0';
		if ((dp = opendir (pathname)) == NULL)
			err_sys ("can't open %s", argv[1]);
		//struct dirent {
		//ino_t          d_ino;       /*  inode number */
		//off_t          d_off;       /*  offset to the next dirent */
		//unsigned short d_reclen;    /*  length of this record */
		//unsigned char  d_type;      /*  type of file; not supported
		//by all file system types */
		//char           d_name[256]; /*  filename */
		//};
		while ((dirp = readdir (dp)) != NULL)
			printf ("%s\n", dirp->d_name);
		closedir (dp);
	}
	return 0;
}
