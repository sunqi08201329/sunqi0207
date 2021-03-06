#include "package.h"

int stat_r(const char *path, struct stat *buf)
{
	int i;
	if((i = stat(path, buf)) == -1)
		err_ret("stat() error");
	return i;
}
int fstat_r(int fd, struct stat *buf)
{
	int i;
	if((i = fstat(fd, buf)) == -1)
		err_ret("fstat() error");
	return i;
}
int lstat_r(const char *path, struct stat *buf)
{
	int i;
	if((i = lstat(path, buf)) == -1)
		err_ret("lstat() error");
	return i;
}
// 	st_mode relation
int access_r(const char *pathname, int mode)
{
	int i;
	if((i = access(pathname, mode) == -1))
		err_sys("access error");
	return i;
}
int fchmod_r(int fd, mode_t mode)
{
	int i;
	if((i = fchmod(fd, mode)) == -1)
		err_ret("fchmod error");
	return i;
}
int chmod_r(const char *path, mode_t mode)
{
	int i;
	if((i = chmod(path, mode)) == -1)
		err_ret("chmod error");
	return i;
}
//	st_uid, st_gid relation
int chown_r(const char *path, uid_t owner, gid_t group)
{
	int i;
	if((i = chown(path, owner, group)) == -1)
		err_ret("chown error");
	return i;
}
int fchown_r(int fd, uid_t owner, gid_t group)
{
	int i;
	if((i = fchown(fd, owner, group)) == -1)
		err_ret("fchown error");
	return i;
}
int lchown_r(const char *path, uid_t owner, gid_t group)
{
	int i;
	if((i = lchown(path, owner, group)) == -1)
		err_ret("lchown(%s, %d, %d) error", path, owner, group);
	return i;
}
//  	st_size relation
int truncate_r(const char *path, off_t length)
{
	int i;
	if((i = truncate(path, length)) == -1)
		err_ret("truncate(%s, %d) error", path, length);
	return i;
}
int ftruncate_r(int fd, off_t length)
{
	int i;
	if((i = ftruncate(fd, length)) == -1)
		err_ret("ftruncate(%d, %d) error", fd, length);
	return i;
}

