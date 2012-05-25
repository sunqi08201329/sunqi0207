/*
 * =====================================================================================
 *
 *       Filename:  p5f1n3_ls.c
 *
 *    Description:  ls_command
 *
 *        Version:  1.0
 *        Created:  2012年04月12日 17时03分36秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *        Company:  
 *
 * =====================================================================================
 */

//------------------------------------------------------------------
//step 1. add include file apue.h dirent.h
//step 2. opendir
//step 3. readdir
//step 4. closedir
//------------------------------------------------------------------
#include "apue.h"
#include <dirent.h>
int
main (int argc, const char *argv[])
{
  DIR *dp;
  struct dirent *dirp;

  if (argc != 2)
    {
      err_quit ("usage: ls directory_name");
    }
  //DIR *opendnr(const char *name);
  //return a pointer to the directory stream. 
  //On error, NULL isreturned,  and errno is set appropriately.
  if ((dp = opendir (argv[1])) == NULL)
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
  return 0;
}
