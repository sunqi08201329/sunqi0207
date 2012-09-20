#include "mesg.h"

ssize_t mesg_send(int fd, struct mymesg *mptr)
{
	return(write(fd, mptr, MESGHDRSIZE + mptr->mesg_len));
}
ssize_t mesg_recv(int fd, struct mymesg *mptr)
{
	size_t	len;
	ssize_t	n;

		/* 4read message header first, to get len of data that follows */
	if ( (n = read_r(fd, mptr, MESGHDRSIZE)) == 0)
		return(0);		/* end of file */
	else if (n != MESGHDRSIZE)
		err_quit("message header: expected %d, got %d", MESGHDRSIZE, n);

	if ( (len = mptr->mesg_len) > 0)
		if ( (n = read_r(fd, mptr->mesg_data, len)) != len)
			err_quit("message data: expected %d, got %d", len, n);
	return(len);
}
ssize_t Mesg_recv(int fd, struct mymesg *mptr)
{
	return(mesg_recv(fd, mptr));
}
void Mesg_send(int fd, struct mymesg *mptr)
{
	ssize_t	n;

	if ( (n = mesg_send(fd, mptr)) != mptr->mesg_len)
		err_quit("mesg_send error");
}
