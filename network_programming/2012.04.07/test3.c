#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define THREADS_NUM	5
#define STRING_LENGTH	32

typedef struct
{
  int id;
  char string[STRING_LENGTH];
} arguments_t;

void *start_routine(void *arg);

int main(int argc, char **argv)
{
  pthread_t tid;
  int code;
  int i;
  arguments_t arguments[THREADS_NUM];

  for (i = 0; i < THREADS_NUM; i++)
  {
    arguments[i].id = i;

    //int snprintf(char *str, size_t size, const char *format, ...);
    snprintf(arguments[i].string, sizeof(arguments[i].string), "Thread #%d", i);

    //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
    code = pthread_create(&tid, NULL, start_routine, &arguments[i]);

    if (code != 0)
    {
      fprintf(stderr, "Create new thread failed: %s\n", strerror(code));
      exit(1);
    }

    fprintf(stdout, "New thread created.\n");

    //sleep(1);
  }

  //sleep(10);
  //void pthread_exit(void *value_ptr);
  pthread_exit((void *) 0);

  //return 0;
}

void *start_routine(void *arg)
{
  int id;

  //int id = (int) arg;
  arguments_t *argument = (arguments_t *) arg;
  id = argument->id;

  for (;;)
  {
    fprintf(stdout, "[Thread #%d] %s:%d:%s() running ...\n", id, __FILE__, __LINE__, __func__);
    fprintf(stdout, "[Thread #%d] id = %d, string: %s\n", id, argument->id, argument->string);

    sleep(1);

  }

  return ((void *) 0);
}

// vim:tabstop=8
