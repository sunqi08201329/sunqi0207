#ifndef __FILE_ERR__
#define  __FILE_ERR__
#include <sys/stat.h>

//struct stat {
	//dev_t     st_dev;     /* ID of device containing file */
	//ino_t     st_ino;     /* inode number */
	//mode_t    st_mode;    /* protection */
	//nlink_t   st_nlink;   /* number of hard links */
	//uid_t     st_uid;     /* user ID of owner */
	//gid_t     st_gid;     /* group ID of owner */
	//dev_t     st_rdev;    /* device ID (if special file) */
	//off_t     st_size;    /* total size, in bytes */
	//blksize_t st_blksize; /* blocksize for file system I/O */
	//blkcnt_t  st_blocks;  /* number of 512B blocks allocated */
	//time_t    st_atime;   /* time of last access */
	//time_t    st_mtime;   /* time of last modification */
	//time_t    st_ctime;   /* time of last status change */
//};
//	get struct stat
int stat_r(const char *path, struct stat *buf);
int fstat_r(int fd, struct stat *buf);
int lstat_r(const char *path, struct stat *buf);
// 	st_mode relation
int access_r(const char *pathname, int mode);
int chmod_r(const char *path, mode_t mode);
int fchmod_r(int fd, mode_t mode);
int chmod_r(const char *path, mode_t mode);
//	st_uid, st_gid relation
int chown_r(const char *path, uid_t owner, gid_t group);
int fchown_r(int fd, uid_t owner, gid_t group);
int lchown_r(const char *path, uid_t owner, gid_t group);
//  	st_size relation
int truncate_r(const char *path, off_t length);
int ftruncate_r(int fd, off_t length);

//-----------------------------------------------------------------------------------------
//	standard library function error process
//-----------------------------------------------------------------------------------------
FILE *fopen_r(const char *path, const char *mode);
FILE *fdopen_r(int fd, const char *mode);
FILE *freopen_r(const char *path, const char *mode, FILE *stream);

#endif  //__FILE_ERR__
