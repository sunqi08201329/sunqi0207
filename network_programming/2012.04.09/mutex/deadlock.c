#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

//--------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------
pthread_mutex_t global_mutex1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t global_mutex2 = PTHREAD_MUTEX_INITIALIZER;

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

  pthread_create(&t1, NULL, t1_main, NULL);
  pthread_create(&t2, NULL, t2_main, NULL);

  pthread_join(t1, NULL);
  pthread_join(t2, NULL);

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Thread #1
//--------------------------------------------------------------------
void *t1_main(void *arg)
{
  for (;;)
  {
    pthread_mutex_lock(&global_mutex1);
    pthread_mutex_lock(&global_mutex2);

    write(1, "+", 1);

    pthread_mutex_unlock(&global_mutex2);
    pthread_mutex_unlock(&global_mutex1);

    //sleep(1);
  }

  pthread_exit((void *) 0);
}

//--------------------------------------------------------------------
// Thread #2
//--------------------------------------------------------------------
void *t2_main(void *arg)
{
  for (;;)
  {
    pthread_mutex_lock(&global_mutex2);
    pthread_mutex_lock(&global_mutex1);

    write(1, "-", 1);

    pthread_mutex_unlock(&global_mutex1);
    pthread_mutex_unlock(&global_mutex2);

    //sleep(1);
  }

  pthread_exit((void *) 0);
}
