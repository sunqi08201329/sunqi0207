#include "package.h"

#include <signal.h>

//void (*signal(int signo, void (*handler)(int))(int));
//use sigaction(2) instead
sighandler_t signal(int signum, sighandler_t handler)
{
	//signal() returns the previous value of the signal handler, or SIG_ERR on error.
	//#define SIG_ERR	((__sighandler_t) -1)		/* Error return.  */
	//#define SIG_DFL	((__sighandler_t) 0)		/* Default action.  */
	//#define SIG_IGN	((__sighandler_t) 1)		/* Ignore signal.  */
	sighandler_t sig_handler;
	if((sig_handler = signal(signum, handler)) == SIG_ERR)
		err_ret("signal() error");
	return sig_handler;
}
