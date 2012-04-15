#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void *start_routine(void *arg);

int main(int argc, char **argv)
{
  pthread_t tid;
  pthread_attr_t attr;
  int code;

  //int pthread_attr_init(pthread_attr_t * attr);
  pthread_attr_init(&attr);

  //int pthread_attr_getdetachstate(const pthread_attr_t * attr, int *detachstate);
  //int pthread_attr_setdetachstate(pthread_attr_t * attr, int detachstate);
  //pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
  code = pthread_create(&tid, &attr, start_routine, NULL);

  if (code != 0)
  {
    fprintf(stderr, "Create new thread failed: %s\n", strerror(code));
    exit(1);
  }

  fprintf(stdout, "New thread created.\n");

  //int pthread_attr_destroy(pthread_attr_t *attr);
  pthread_attr_destroy(&attr);

  //sleep(1);

  //int pthread_detach(pthread_t thread);
  code = pthread_detach(tid);

  if (code != 0)
  {
    fprintf(stderr, "Detach target thread failed: %s\n", strerror(code));
  }
  else
  {
    fprintf(stdout, "Detach target thread success.\n");
  }

  int return_value;

  //int pthread_join(pthread_t thread, void **value_ptr);
  code = pthread_join(tid, (void **) &return_value);

  if (code != 0)
  {
    fprintf(stderr, "pthread_join() failed: %s\n", strerror(code));
  }
  else
  {
    fprintf(stdout, "pthread_join() success, target thread terminatd, return_value = %d\n", return_value);
  }

  //sleep(10);
  //void pthread_exit(void *value_ptr);
  pthread_exit((void *) 0);

  //return 0;
}

void *start_routine(void *arg)
{
  fprintf(stdout, "%s:%d:%s() running ...\n", __FILE__, __LINE__, __func__);

#if 0
  int code;

  //int pthread_detach(pthread_t thread);
  //pthread_t pthread_self(void);
  code = pthread_detach(pthread_self());

  if (code != 0)
  {
    fprintf(stderr, "Detach myself failed: %s\n", strerror(code));
  }
  else
  {
    fprintf(stdout, "Detach myself success.\n");
  }

  sleep(5);
#endif

  //void pthread_exit(void *value_ptr);
  pthread_exit((void *) 256);

  return ((void *) 987);
}

// vim:tabstop=8
