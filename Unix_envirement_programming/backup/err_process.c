#include "apue.h"
void mkfifo_r(const char *pathname, mode_t mode, int flag)
{
	if(mkfifo(pathname, mode) < 0){
		fprintf(stderr, "mkfifo error(%s) for %s\n", strerror(errno), pathname);
		if(flag == 1){
			unlink(pathname);
		} else {
			exit(1);
		}
	}
}
void FIFO_send_commands(const char *pathname, char *commands)
{
    int fifo_fd = -1;	
    
    fifo_fd = open_r(pathname, O_WRONLY|O_NONBLOCK);
    
    if(write_r(fifo_fd, commands , WRITE_SIZE) != -1)
    {
        printf("Send Data to FIFO sucessful\n");
    }
    
    close(fifo_fd);
}
void FIFO_get_commands(const char *pathname)
{
	int fifo_fd = -1;
	char dbuf[1024];

	unlink(pathname);

	mkfifo_r(pathname, O_CREAT|O_EXCL, 1);

	fifo_fd = open_r(pathname, O_RDONLY);

	for(;;) 
	{
		memset(dbuf, 0x00, sizeof(dbuf));

		if(read_r(fifo_fd, dbuf, sizeof(dbuf)) > 0)
		{
			printf("Get Cmd is :%s\n", dbuf); 
			system(dbuf);
		}
		sleep(1);
	} 

	close(fifo_fd);
	unlink(pathname);
}
/*
 * QUEUE_MESSAGE COMUNIOCATION
 */
int msgget_r(key_t key, int msgflag)
{
	int msg_id = -1;
	if((msg_id = msgget(key, msgflag)) == -1){
		fprintf(stderr, "mesget error(%s) for %d\n", strerror(errno), key);
		exit(1);
	}
	return msg_id;
}
int msgrcv_r(int msg_id, void *msgp, size_t msg_size,long msg_type, int msgflag)
{
	int rcv_bytes = 0;
	if((rcv_bytes = msgrcv(msg_id, msgp, msg_size, msg_type, msgflag)) == -1){
		fprintf(stderr, "mesrcv error(%s) for %d\n", strerror(errno), msg_id);
		return rcv_bytes;
	}
	return rcv_bytes;
}
void msgsnd_r(int msg_id, const void *msgp, size_t msg_size, int msgflag)
{
	if(msgsnd(msg_id, msgp, msg_size, msgflag) == -1){
		fprintf(stderr, "messnd error(%s) for %d\n", strerror(errno), msg_id);
		exit(1);
	}
}
int QU_MSG_recivice()
{
	struct m_msg_t msg_q_r;
	int msg_id = -1;
	int msg_rx = 0;
	int rcv_bytes = 0;

	msg_id = msgget_r((key_t)MSG_KEY, 0777|IPC_CREAT);

	for(;;)
	{
		rcv_bytes = msgrcv_r(msg_id,(void *)&msg_q_r, sizeof(struct m_msg_t), msg_rx, 0);

		printf("Receive Message Type is : %d\n", msg_q_r.msg_type);
		printf("Receive Message Date is : %s\n", msg_q_r.msg_data);

		sleep(1);
	}
	return rcv_bytes;
}
void QU_MSG_send()
{
    struct m_msg_t msg_q_s;
    int msg_id = -1;
    char dbuf[MSG_DATA_MAX]; 
    
    msg_id = msgget((key_t)MSG_KEY, 0777|IPC_CREAT);
    
    printf("Please Enter Message to Send:");  
    fgets(dbuf, MSG_DATA_MAX, stdin);
    
    msg_q_s.msg_type = 1;
    
    strcpy(msg_q_s.msg_data, dbuf);  
    
    msgsnd_r(msg_id, (void *)&msg_q_s, sizeof(struct m_msg_t), 0);
	
}
/*
 * PIPE
 */
void pipe_r(int *fd)
{
	if(pipe(fd) < 0){
		perror("pipe"):
		exit(1);
	}
}
int fork_r(void)
{	
	int pid;
	if((pid = fork()) < 0){
		perror("fork");
		exit(1);
	}
	return pid;
}
