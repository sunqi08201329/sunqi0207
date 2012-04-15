#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define THREADS_NUM	5

void *start_routine(void *arg);

int main(int argc, char **argv)
{
  pthread_t tid;
  int id[THREADS_NUM];
  int code;
  int i;

  for (i = 0; i < THREADS_NUM; i++)
  {
    id[i] = i;

    //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
    code = pthread_create(&tid, NULL, start_routine, &id[i]);

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
  int id = *(int *) arg;

  fprintf(stdout, "%s:%d:%s() running ...\n", __FILE__, __LINE__, __func__);
  fprintf(stdout, "id = %d\n", id);

  return ((void *) 0);
}

// vim:tabstop=8
