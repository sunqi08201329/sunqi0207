#ifndef __PACKAGE__H__
#define  __PACKAGE__H__

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>		/* for definition of errno */
#include <string.h>
#include <stdarg.h>		/* ISO C variable aruments */
#include <signal.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/socket.h>

#define	MAXLINE	4096			/* max line length */

/*
 *	signal relative function package process 	"signal_err.c"
 */
typedef void (*sighandler_t)(int);
sighandler_t signal(int signum, sighandler_t handler);
/*
 *	error relative function package process		"error.c"
 */
void	err_dump(const char *, ...);		/* {App misc_source} */
void	err_msg(const char *, ...);
void	err_quit(const char *, ...);
void	err_exit(int, const char *, ...);
void	err_ret(const char *, ...);
void	err_sys(const char *, ...);
/*
 *	file system relative function package process		"file_err.c"
 */
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
/*get struct stat*/
int stat_r(const char *path, struct stat *buf);
int fstat_r(int fd, struct stat *buf);
int lstat_r(const char *path, struct stat *buf);
/*st_mode relation*/
int access_r(const char *pathname, int mode);
int chmod_r(const char *path, mode_t mode);
int fchmod_r(int fd, mode_t mode);
int chmod_r(const char *path, mode_t mode);
/*st_uid, st_gid relation*/
int chown_r(const char *path, uid_t owner, gid_t group);
int fchown_r(int fd, uid_t owner, gid_t group);
int lchown_r(const char *path, uid_t owner, gid_t group);
/*st_size relation*/
int truncate_r(const char *path, off_t length);
int ftruncate_r(int fd, off_t length);
/*
 *	stardard library relative function package process	"stream_err.c"
 */
FILE *fopen_r(const char *path, const char *mode);
FILE *fdopen_r(int fd, const char *mode);
FILE *freopen_r(const char *path, const char *mode, FILE *stream);
char *fgets_r(char *s, int size, FILE *stream);
void fputs_r(const char *buf, FILE *stream);
/*
 *	socket relative function package process	"socket_err.c"
 */
int socket_r(int domain, int type, int protocol);
void bind_r(int listening_socket, const struct sockaddr *addr, socklen_t addrlen, void *arg);
void listen_r(int sockfd, int backlog, void *arg);
void connect_r(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen, void *arg);
int accept_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
void close_r(int fd);
ssize_t read_r(int fd, void *ptr, size_t nbytes);
ssize_t write_r(int fd, const void *ptr, size_t nbytes);
ssize_t send_r(int new_connected_socket, const void *buf, size_t len, int flags);
ssize_t recv_r(int new_connected_socket, void *buf, size_t len, int flags);
/*socket optional*/
int setsockopt_r(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
int getsockopt_r(int sockfd, int level, int optname, void *optval, socklen_t *optlen);
/*get sockaddr*/
int getsockname_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
int getpeername_r(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
/*
 * 	convert relative function package process 	"convert_func_err.c"
 */
int inet_pton_r(int af, const char *src, void *dst);
const char *inet_ntop_r(int af, const void *src, char *dst, socklen_t cnt);
/*
 * 	unix func 						"wrapunix.c"
 */
void * calloc_r(size_t n, size_t size);
void dup2_r(int fd1, int fd2);
int fcntl_r(int fd, int cmd, int arg);
void gettimeofday_r(struct timeval *tv, void *foo);
int ioctl_r(int fd, int request, void *arg);
pid_t fork_r(void);
void * malloc_r(size_t size);
void * mmap_r(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
int open_r(const char *pathname, int oflag, mode_t mode);
void pipe_r(int *fds);
void sigaddset_r(sigset_t *set, int signo);
void sigdelset_r(sigset_t *set, int signo);
void sigemptyset_r(sigset_t *set);
void sigfillset_r(sigset_t *set);
int sigismember_r(const sigset_t *set, int signo);
void sigpending_r(sigset_t *set);
void sigprocmask_r(int how, const sigset_t *set, sigset_t *oset);
void unlink_r(const char *pathname);
pid_t wait_r(int *iptr);
pid_t waitpid_r(pid_t pid, int *iptr, int options);

#endif // __PACKAGE__H__
