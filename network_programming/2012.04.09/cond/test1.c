#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

//--------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------
int global_value = 0;
pthread_mutex_t global_value_mutex = PTHREAD_MUTEX_INITIALIZER;

//--------------------------------------------------------------------
// Function prototype
//--------------------------------------------------------------------
void *producer(void *arg);
void *consumer(void *arg);

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  pthread_t t1, t2;
  int code;

  //int pthread_create(pthread_t * restrict thread, const pthread_attr_t * restrict attr, void *(*start_routine) (void *), void *restrict arg);
  code = pthread_create(&t1, NULL, producer, NULL);

  if (code != 0)
  {
    fprintf(stderr, "Create producer thread failed: %s\n", strerror(code));
    exit(1);
  }

  fprintf(stdout, "Producer thread created.\n");

  code = pthread_create(&t2, NULL, consumer, NULL);

  if (code != 0)
  {
    fprintf(stderr, "Create consumer thread failed: %s\n", strerror(code));
    exit(1);
  }

  fprintf(stdout, "Consumer thread created.\n");

  //int pthread_join(pthread_t thread, void **value_ptr);
  pthread_join(t1, NULL);
  pthread_join(t2, NULL);

  pthread_mutex_destroy(&global_value_mutex);

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Consumer thread
//--------------------------------------------------------------------
void *consumer(void *arg)
{
  for (;;)
  {
    pthread_mutex_lock(&global_value_mutex);

    fprintf(stdout, "[C] checking ...\n");

    if (global_value > 100)
    {
      fprintf(stdout, "[C] ready to do something ...\n");
      global_value -= 100;
    }

    pthread_mutex_unlock(&global_value_mutex);

    sleep(1);
  }

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Producer thread
//--------------------------------------------------------------------
void *producer(void *arg)
{
  for (;;)
  {
    pthread_mutex_lock(&global_value_mutex);

    global_value += 10;
    fprintf(stdout, "[P] global_value = %d\n", global_value);

    pthread_mutex_unlock(&global_value_mutex);

    sleep(1);
  }

  pthread_exit((void *) 0);
}

// vim:tabstop=8
