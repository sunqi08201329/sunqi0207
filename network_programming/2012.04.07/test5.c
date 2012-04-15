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

  //------------------------------------------------------------------
  // Initialize attr object
  //------------------------------------------------------------------
  //int pthread_attr_init(pthread_attr_t *attr);
  pthread_attr_init(&attr);

  //------------------------------------------------------------------
  // Modify attr object
  //------------------------------------------------------------------
  int default_detachstate;

  // PTHREAD_CREATE_DETACHED or PTHREAD_CREATE_JOINABLE

  //int pthread_attr_getdetachstate(const pthread_attr_t * attr, int *detachstate);
  pthread_attr_getdetachstate(&attr, &default_detachstate);

  fprintf(stdout, "Default detachstate: %s\n", default_detachstate == PTHREAD_CREATE_DETACHED ? "Detached" : "Joinable");

  //int pthread_attr_setdetachstate(pthread_attr_t * attr, int detach - state);
  //pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  //pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  size_t default_stacksize;

  //int pthread_attr_getstacksize(const pthread_attr_t * restrict attr, size_t * restrict stacksize);
  pthread_attr_getstacksize(&attr, &default_stacksize);

  fprintf(stdout, "Default stack size: %d\n", default_stacksize);

  size_t new_stack_size = 1024 * 1024;

  //int pthread_attr_setstacksize(pthread_attr_t * attr, size_t stack - size);
  pthread_attr_setstacksize(&attr, new_stack_size);

  size_t default_guardsize;

  //int pthread_attr_getguardsize(const pthread_attr_t * restrict attr, size_t * restrict guardsize);
  pthread_attr_getguardsize(&attr, &default_guardsize);

  fprintf(stdout, "Default guard size: %d\n", default_guardsize);

  size_t new_guard_size = 0;

  //int pthread_attr_setguardsize(pthread_attr_t * attr, size_t guardsize);
  pthread_attr_setguardsize(&attr, new_guard_size);

  //------------------------------------------------------------------
  // Create new thread use attr object
  //------------------------------------------------------------------
  //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
  code = pthread_create(&tid, &attr, start_routine, NULL);

  if (code != 0)
  {
    fprintf(stderr, "Create new thread failed: %s\n", strerror(code));
    exit(1);
  }

  fprintf(stdout, "New thread created.\n");

  //------------------------------------------------------------------
  // Destroy attr object
  //------------------------------------------------------------------
  //int pthread_attr_destroy(pthread_attr_t *attr);
  pthread_attr_destroy(&attr);

  //int pthread_join(pthread_t thread, void **value_ptr);
  code = pthread_join(tid, NULL);

  if (code != 0)
  {
    fprintf(stderr, "Join target thread failed: %s\n", strerror(code));
  }
  else
  {
    fprintf(stdout, "Join target thread success.\n");
  }

  //sleep(10);
  //void pthread_exit(void *value_ptr);
  pthread_exit((void *) 0);

  //return 0;
}

void *start_routine(void *arg)
{
  fprintf(stdout, "%s:%d:%s() running ...\n", __FILE__, __LINE__, __func__);

  char buffer[1024 * 1024];

  buffer[sizeof(buffer) - 1024] = 'x';

  return ((void *) 0);
}

// vim:tabstop=8
