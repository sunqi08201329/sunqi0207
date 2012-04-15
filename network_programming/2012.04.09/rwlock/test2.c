#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

//--------------------------------------------------------------------
// Macro definition
//--------------------------------------------------------------------
#define THREADS_NUM	20

//--------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------
int global_value = 0;
pthread_rwlock_t global_value_rwlock;

//--------------------------------------------------------------------
// Function prototype
//--------------------------------------------------------------------
void *writer(void *arg);
void *reader(void *arg);

//--------------------------------------------------------------------
// Main funciton
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  pthread_t threads[THREADS_NUM];
  int i;

  //int pthread_rwlock_init(pthread_rwlock_t * restrict rwlock, const pthread_rwlockattr_t * restrict attr);
  pthread_rwlock_init(&global_value_rwlock, NULL);

  for (i = 0; i < THREADS_NUM; i++)
  {
    if (i % 8 == 0)
    {
      // create writer
      pthread_create(&threads[i], NULL, writer, (void *) i);
    }
    else
    {
      // create reader
      pthread_create(&threads[i], NULL, reader, (void *) i);
    }
  }

  for (i = 0; i < THREADS_NUM; i++)
  {
    pthread_join(threads[i], NULL);
  }
  
  //int pthread_rwlock_destroy(pthread_rwlock_t * rwlock);
  pthread_rwlock_destroy(&global_value_rwlock);

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Writer thread
//--------------------------------------------------------------------
void *writer(void *arg)
{
  int id = (int) arg;

  for (;;)
  {
    pthread_rwlock_wrlock(&global_value_rwlock);

    global_value++;
    //fprintf(stdout, "[W%02d]global_value = %d\n", id, global_value);
    fprintf(stdout, "\033[0;34;20m[W%02d]: Attempt to write ...\033[0m\n", id);

    sleep((id + 1) % 3);

    pthread_rwlock_unlock(&global_value_rwlock);

    sleep((id * id) % 3 + 3);
  }

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Reader thread
//--------------------------------------------------------------------
void *reader(void *arg)
{
  int id = (int) arg;

  for (;;)
  {
    pthread_rwlock_rdlock(&global_value_rwlock);

    fprintf(stdout, "[R%02d]global_value = %d\n", id, global_value);
    sleep((id + 1) % 3);

    pthread_rwlock_unlock(&global_value_rwlock);

    sleep((id * id) % 3 + 1);
  }

  pthread_exit((void *) 0);
}

// vim:tabstop=8
