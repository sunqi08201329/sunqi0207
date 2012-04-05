#ifndef _APUE_H_
#define _APUE_H_
#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <errno.h>

#define WRITE_SIZE 30

#define MSG_DATA_MAX 1024
#define MSG_KEY      1234

struct m_msg_t
{  
   int msg_type;
   char msg_data[MSG_DATA_MAX];  
};

extern void stat_r(const char * pathname, struct stat *buf);
extern void chmod_r(const char * pathname, mode_t mode);
extern int open_r(const char * pathname, int flags);
extern int write_r(int filedes, char *data, size_t bytes);
extern int read_r(int filedes, char *data, size_t bytes);
/*
 *FIFO INTERPROCESS COMUNICATION
 */
extern void mkfifo_r(const char *pathname, mode_t mode, int flag);
extern void FIFO_send_commands(const char *pathname, char *commands);
extern void FIFO_get_commands(const char *pathname);
/*
 * QUEUE_MESSAGE COMUNIOCATION
 */
extern int msgget_r(key_t key, int msgflag);
extern int msgrcv_r(int msg_id, void *msgp, size_t msg_size,long msg_type, int msgflag);
extern void msgsnd_r(int msg_id, const void *msgp, size_t msg_size, int msgflag);
extern int QU_MSG_recivice();
extern void QU_MSG_send();
/*
 * PIPE
 */
extern void pipe_r(int *fd);
extern int fork_r(void);
#endif //_APUE_H_
