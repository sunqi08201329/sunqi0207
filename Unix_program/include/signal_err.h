#ifndef __SIGNAL_ERR__
#define  __SIGNAL_ERR__ 
typedef void (*sighandler_t)(int);
sighandler_t signal(int signum, sighandler_t handler);

#endif  //__SIGNAL_ERR__
