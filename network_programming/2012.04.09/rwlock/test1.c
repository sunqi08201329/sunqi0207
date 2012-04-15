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
pthread_mutex_t global_value_mutex = PTHREAD_MUTEX_INITIALIZER;

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
    pthread_mutex_lock(&global_value_mutex);

    global_value++;
    fprintf(stdout, "[W%02d]global_value = %d\n", id, global_value);

    sleep((id + 1) % 3);

    pthread_mutex_unlock(&global_value_mutex);

    sleep((id * id + 2) % 3);
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
    pthread_mutex_lock(&global_value_mutex);

    fprintf(stdout, "[R%02d]global_value = %d\n", id, global_value);
    sleep((id + 1) % 3);

    pthread_mutex_unlock(&global_value_mutex);

    sleep((id * id) % 3 + 1);
  }

  pthread_exit((void *) 0);
}

// vim:tabstop=8
