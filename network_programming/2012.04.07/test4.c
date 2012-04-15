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
  // detachstate attribute
  //------------------------------------------------------------------
  int default_detachstate;

  // PTHREAD_CREATE_DETACHED or PTHREAD_CREATE_JOINABLE

  //int pthread_attr_getdetachstate(const pthread_attr_t * attr, int *detachstate);
  pthread_attr_getdetachstate(&attr, &default_detachstate);

  fprintf(stdout, "Default detachstate: %d(%s)\n", default_detachstate, default_detachstate == PTHREAD_CREATE_DETACHED ? "Detached" : "Joinable");

  //int pthread_attr_setdetachstate(pthread_attr_t * attr, int detach - state);
  //pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  //pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  //------------------------------------------------------------------
  // stack size attribute
  //------------------------------------------------------------------
  size_t default_stacksize;

  //int pthread_attr_getstacksize(const pthread_attr_t * restrict attr, size_t * restrict stacksize);
  pthread_attr_getstacksize(&attr, &default_stacksize);

  fprintf(stdout, "Default stack size: %d\n", default_stacksize);

  //int pthread_attr_setstacksize(pthread_attr_t * attr, size_t stack - size);
  pthread_attr_setstacksize(&attr, default_stacksize / 2);

  //------------------------------------------------------------------
  // guard size attribute
  //------------------------------------------------------------------
  size_t default_guardsize;

  //int pthread_attr_getguardsize(const pthread_attr_t * restrict attr, size_t * restrict guardsize);
  pthread_attr_getguardsize(&attr, &default_guardsize);

  fprintf(stdout, "Default guard size: %d\n", default_guardsize);

  //int pthread_attr_setguardsize(pthread_attr_t * attr, size_t guardsize);

  //------------------------------------------------------------------
  // inheritssched attribute
  //------------------------------------------------------------------
  int default_inheritsched;

  //int pthread_attr_getinheritsched(const pthread_attr_t * restrict attr, int *restrict inheritsched);
  pthread_attr_getinheritsched(&attr, &default_inheritsched);

  // PTHREAD_INHERIT_SCHED and PTHREAD_EXPLICIT_SCHED
  fprintf(stdout, "Default inheritsched: %d(%s)\n", default_inheritsched, default_inheritsched == PTHREAD_INHERIT_SCHED ? "Inherit" : "Explicit");

  //int pthread_attr_setinheritsched(pthread_attr_t * attr, int inheritsched);

  //------------------------------------------------------------------
  // schedpolicy attribute
  //------------------------------------------------------------------
  int default_sched_policy;

  //int pthread_attr_getschedpolicy(const pthread_attr_t * restrict attr, int *restrict policy);
  pthread_attr_getschedpolicy(&attr, &default_sched_policy);

  //SCHED_FIFO, SCHED_RR, and SCHED_OTHER

  fprintf(stdout, "Default schedule policy: %d", default_sched_policy);

  switch (default_sched_policy)
  {
    case SCHED_FIFO:
      fprintf(stdout, "(%s)", "FIFO");
      break;
    case SCHED_RR:
      fprintf(stdout, "(%s)", "RR");
      break;
    case SCHED_OTHER:
      fprintf(stdout, "(%s)", "OTHER");
      break;
#ifdef SCHED_SPORADIC
    case SCHED_SPORADIC:
      fprintf(stdout, "(%s)", "SPORADIC");
      break;
#endif
  }

  fprintf(stdout, "\n");

  //int pthread_attr_setschedpolicy(pthread_attr_t * attr, int policy);

  //------------------------------------------------------------------
  // schedparam attribute
  //------------------------------------------------------------------
  //int pthread_attr_getschedparam(const pthread_attr_t * restrict attr, struct sched_param *restrict param);
  //int pthread_attr_setschedparam(pthread_attr_t * restrict attr, const struct sched_param *restrict param);

  int i;

  for (i = 0;; i++)
  {
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

    fprintf(stdout, "New thread #%d created.\n", i);
  }

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

  return ((void *) 0);
}

// vim:tabstop=8
