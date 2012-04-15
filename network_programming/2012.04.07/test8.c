#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

//--------------------------------------------------------------------
// Function prototype
//--------------------------------------------------------------------
void *start_routine(void *arg);
void cleanup_function1(void *arg);
void cleanup_function2(void *arg);
void free_memory(void *p);
void close_file(void *arg);

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  pthread_t tid;
  int code;

  //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
  code = pthread_create(&tid, NULL, start_routine, NULL);

  if (code != 0)
  {
    fprintf(stderr, "Create new thread failed: %s\n", strerror(code));
    exit(1);
  }

  fprintf(stdout, "New thread created.\n");

  sleep(5);

  //------------------------------------------------------------------
  // Send cancel request to target thread
  //------------------------------------------------------------------
  //int pthread_cancel(pthread_t thread);
  code = pthread_cancel(tid);

  if (code != 0)
  {
    fprintf(stderr, "Send cancel request to target thread failed: %s\n", strerror(code));
  }
  else
  {
    fprintf(stdout, "Send cancel request to target thread successfully.\n");
  }

  //------------------------------------------------------------------
  // Wait for target thread
  //------------------------------------------------------------------
  pthread_join(tid, NULL);

  sleep(100);

  //------------------------------------------------------------------
  // Terminate main thread
  //------------------------------------------------------------------
  //void pthread_exit(void *value_ptr);
  pthread_exit((void *) 0);

  //return 0;
}

//--------------------------------------------------------------------
// Thread's main function
//--------------------------------------------------------------------
void *start_routine(void *arg)
{
  int oldstate;
  int oldtype;
  char *p = NULL;
  int fd;

  //PTHREAD_CANCEL_DEFERRED & PTHREAD_CANCEL_ASYNCHRONOUS

  //int pthread_setcanceltype(int type, int *oldtype);
  pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, &oldtype);
  //pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, &oldtype);

  //------------------------------------------------------------------
  // Set cancel state to disable to protect memory allocation
  //------------------------------------------------------------------
  //int pthread_setcancelstate(int state, int *oldstate);
  pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldstate);

  p = malloc(1024);

  if (p == NULL)
  {
    fprintf(stderr, "Allocate memory failed.\n");
  }

  //int pthread_setcancelstate(int state, int *oldstate);
  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &oldstate);

  //------------------------------------------------------------------
  // Set cancel state to disable to protect opening file
  //------------------------------------------------------------------
  //int pthread_setcancelstate(int state, int *oldstate);
  pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldstate);

  //int open(const char *pathname, int flags);
  fd = open("test8", O_RDONLY);

  if (fd < 0)
  {
    fprintf(stderr, "Open file %s failed: %s\n", "test8", strerror(errno));
  }
  else
  {
    fprintf(stdout, "Open file %s successfully, fd = %d\n", "test8", fd);
  }


  //int pthread_setcancelstate(int state, int *oldstate);
  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &oldstate);

  pthread_cleanup_push(free_memory, (void *) p);
  pthread_cleanup_push(close_file, (void *) fd);

  fprintf(stdout, "%s:%d:%s() running ...\n", __FILE__, __LINE__, __func__);

#if 0
  //void pthread_cleanup_push(void (*routine) (void *), void *arg);
  pthread_cleanup_push(cleanup_function1, (void *) 1);
  pthread_cleanup_push(cleanup_function1, (void *) 2);
  pthread_cleanup_push(cleanup_function2, p);
  pthread_cleanup_push(cleanup_function1, (void *) 3);
#endif

  int i;

  for (i = 0; i < 50; i++)
  {
    pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldstate);

    write(1, ".", 1);
    sleep(1);
    
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &oldstate);

    //void pthread_testcancel(void);
    pthread_testcancel();	// one and only cancellation point
  }

#if 0
  //void pthread_cleanup_pop(int execute);
  pthread_cleanup_pop(0);
  pthread_cleanup_pop(1);
  pthread_cleanup_pop(1);
  pthread_cleanup_pop(1);
#endif

  pthread_cleanup_pop(0);
  pthread_cleanup_pop(0);

  //int pthread_setcancelstate(int state, int *oldstate);
  pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldstate);

  fprintf(stdout, "Manually free memory and close file.\n");

  if (p != NULL)
  {
    free(p);
  }

  if (fd >= 0)
  {
    close(fd);
  }

  //int pthread_setcancelstate(int state, int *oldstate);
  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &oldstate);

  return ((void *) 0);
}

//--------------------------------------------------------------------
// Cleanup handlers
//--------------------------------------------------------------------
void cleanup_function1(void *arg)
{
  int value = (int) arg;

  char buffer[1024];

  //fprintf(stdout, "Calling %s:%d:%s() with arg %d\n", __FILE__, __LINE__, __func__, value);

  //int snprintf(char *str, size_t size, const char *format, ...);
  snprintf(buffer, sizeof(buffer) - 1, "Calling %s:%d:%s() with arg %d\n", __FILE__, __LINE__, __func__, value);

  // ssize_t write(int fd, const void *buf, size_t count);
  write(1, buffer, strlen(buffer));
}

void cleanup_function2(void *arg)
{
  char buffer[1024];
  char *p = (char *) arg;

  //fprintf(stdout, "Calling %s:%d:%s() with arg %p\n", __FILE__, __LINE__, __func__, p);

  //int snprintf(char *str, size_t size, const char *format, ...);
  snprintf(buffer, sizeof(buffer) - 1, "Calling %s:%d:%s() with arg %p\n", __FILE__, __LINE__, __func__, p);

  // ssize_t write(int fd, const void *buf, size_t count);
  write(1, buffer, strlen(buffer));
}

void free_memory(void *p)
{
  if (p)
  {
    free(p);
    p = NULL;
  }

  fprintf(stdout, "Cancellation cleanup handler: memory freed.\n");
}

void close_file(void *arg)
{
  int fd = (int) arg;

  if (fd >= 0)
  {
    close(fd);
  }

  fprintf(stdout, "Cancellation cleanup handler: file closed.\n");
}

// vim:tabstop=8
