#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <semaphore.h>

//--------------------------------------------------------------------
// Macro definition
//--------------------------------------------------------------------
#define NUM	100000
#define THREADS_NUM	10

//--------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------
int global_value = 0;
sem_t global_value_sem;

//--------------------------------------------------------------------
// Function prototype
//--------------------------------------------------------------------
void *consumer_main(void *arg);

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char **argv)
{
  pthread_t threads[THREADS_NUM];
  int code;

  //int sem_init(sem_t *sem, int pshared, unsigned int value);
  sem_init(&global_value_sem, 0, 3);

  int i;

  for (i = 0; i < THREADS_NUM; i++)
  {
    code = pthread_create(&threads[i], NULL, consumer_main, (void *) i);
  }

  for (i = 0; i < THREADS_NUM; i++)
  {
    pthread_join(threads[i], NULL);
  }

  //int sem_destroy(sem_t *sem);
  sem_destroy(&global_value_sem);

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Thread #1 
//--------------------------------------------------------------------
void *consumer_main(void *arg)
{
  int id = (int) arg;

  for (;;)
  {
    //int sem_wait(sem_t *sem);
    sem_wait(&global_value_sem);

    global_value++;

    int sem_value;

    //int sem_getvalue(sem_t *sem, int *sval);
    sem_getvalue(&global_value_sem, &sem_value);

    fprintf(stdout, "[Thread #%02d] Acquire resource, sem_value = %d \n", id, sem_value);
    
    sleep(1);

    //int sem_post(sem_t *sem);
    sem_post(&global_value_sem);

    sleep(id+1);
  }

  pthread_exit((void *) 0);
}

// vim:tabstop=8
