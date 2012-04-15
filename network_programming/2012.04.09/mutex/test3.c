#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

//--------------------------------------------------------------------
// Macro definition
//--------------------------------------------------------------------
#define NUM	100000

//--------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------
int global_value = 0;
//pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t global_value_mutex;

//--------------------------------------------------------------------
// Function prototype
//--------------------------------------------------------------------
void *t1_main(void *arg);
void *t2_main(void *arg);

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  pthread_t t1, t2;
  pthread_mutexattr_t mutexattr;
  int code;

  //int pthread_mutexattr_init(pthread_mutexattr_t * attr);
  pthread_mutexattr_init(&mutexattr);

  //------------------------------------------------------------------
  // mutex type attribute
  //------------------------------------------------------------------
#if 0
  //int pthread_mutexattr_gettype(const pthread_mutexattr_t * restrict attr, int *restrict type);
  //int pthread_mutexattr_settype(pthread_mutexattr_t * attr, int type);
  pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_ERRORCHECK);
  //pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_NORMAL); 
  //pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE); 
  //pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_DEFAULT); 
#endif

  //------------------------------------------------------------------
  // process-shared attribute
  //------------------------------------------------------------------
  //int pthread_mutexattr_getpshared(const pthread_mutexattr_t * restrict attr, int *restrict pshared);
  //int pthread_mutexattr_setpshared(pthread_mutexattr_t * attr, int pshared);

  //------------------------------------------------------------------
  // process attribute
  //------------------------------------------------------------------
  //int pthread_mutexattr_getprotocol(const pthread_mutexattr_t * restrict attr, int *restrict protocol);
  //int pthread_mutexattr_setprotocol(pthread_mutexattr_t * attr, int protocol);

  //------------------------------------------------------------------
  // priority celing attribute
  //------------------------------------------------------------------
  //int pthread_mutexattr_getprioceiling(const pthread_mutexattr_t * restrict attr, int *restrict prioceiling);
  //int pthread_mutexattr_setprioceiling(pthread_mutexattr_t * attr, int prioceiling);

  //int pthread_mutex_init(pthread_mutex_t * restrict mutex, const pthread_mutexattr_t * restrict attr);
  pthread_mutex_init(&global_value_mutex, &mutexattr);

  //int pthread_mutexattr_destroy(pthread_mutexattr_t * attr);
  pthread_mutexattr_destroy(&mutexattr);

  //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
  code = pthread_create(&t1, NULL, t1_main, NULL);

  if (code != 0)
  {
    // failed
    fprintf(stderr, "Create new thread t1 failed: %s\n", strerror(code));
    exit(1);
  }
  else
  {
    // success
    fprintf(stdout, "New thread t1 created.\n");
  }

  //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
  code = pthread_create(&t2, NULL, t2_main, NULL);

  if (code != 0)
  {
    // failed
    fprintf(stderr, "Create new thread t2 failed: %s\n", strerror(code));
    exit(1);
  }
  else
  {
    // success
    fprintf(stdout, "New thread t2 created.\n");
  }

  pthread_join(t1, NULL);
  pthread_join(t2, NULL);

  //int pthread_mutex_destroy(pthread_mutex_t * mutex);
  pthread_mutex_destroy(&global_value_mutex);

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Thread #1
//--------------------------------------------------------------------
void *t1_main(void *arg)
{
  int i;

  for (i = 0; i < NUM; i++)
  {
    //int pthread_mutex_lock(pthread_mutex_t * mutex);
    //int pthread_mutex_trylock(pthread_mutex_t * mutex);
    pthread_mutex_lock(&global_value_mutex);

    global_value++;
    fprintf(stdout, "[Thread #t1]global_value = %d\n", global_value);

    //int pthread_mutex_unlock(pthread_mutex_t * mutex);
    pthread_mutex_unlock(&global_value_mutex);

    sleep(1);
  }

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Thread #2
//--------------------------------------------------------------------
void *t2_main(void *arg)
{
  int i;

  for (i = 0; i < NUM; i++)
  {
    //int pthread_mutex_lock(pthread_mutex_t * mutex);
    //int pthread_mutex_trylock(pthread_mutex_t * mutex);
    pthread_mutex_lock(&global_value_mutex);

    global_value += 2;
    fprintf(stdout, "[Thread #t2]global_value = %d\n", global_value);

    //int pthread_mutex_unlock(pthread_mutex_t * mutex);
    pthread_mutex_unlock(&global_value_mutex);

    sleep(1);
  }

  pthread_exit((void *) 0);
}

// vim:tabstop=8
