#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void *start_routine(void *arg);
void cleanup_function1(void *arg);
void cleanup_function2(void *arg);

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

  pthread_join(tid, NULL);

  //void pthread_exit(void *value_ptr);
  pthread_exit((void *) 0);

  //return 0;
}

void *start_routine(void *arg)
{
  char *p = NULL;

  //p = malloc(1024);

  fprintf(stdout, "%s:%d:%s() running ...\n", __FILE__, __LINE__, __func__);

  //void pthread_cleanup_push(void (*routine) (void *), void *arg);
  pthread_cleanup_push(cleanup_function1, (void *) 1);
  pthread_cleanup_push(cleanup_function1, (void *) 2);
  pthread_cleanup_push(cleanup_function2, p);
  pthread_cleanup_push(cleanup_function1, (void *) 3);

  sleep(3);

  pthread_cleanup_pop(0);

  //return ((void *)0);
  pthread_exit((void *) 0);

  fprintf(stdout, "here!\n");

  //void pthread_cleanup_pop(int execute);
  pthread_cleanup_pop(1);
  pthread_cleanup_pop(1);
  pthread_cleanup_pop(1);

  return ((void *) 0);
}

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

// vim:tabstop=8
