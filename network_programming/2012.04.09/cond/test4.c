#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

//--------------------------------------------------------------------
// Macro definition
//--------------------------------------------------------------------
#define THREADS_NUM	20

//--------------------------------------------------------------------
// Type definition
//--------------------------------------------------------------------
struct msg
{
  struct msg *next;
  int num;
};

//--------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------
struct msg *head;
pthread_cond_t has_product = PTHREAD_COND_INITIALIZER;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

//--------------------------------------------------------------------
// Consumer thread
//--------------------------------------------------------------------
void *consumer(void *p)
{
  int id = (int) p;

  struct msg *mp;

  for (;;)
  {
    pthread_mutex_lock(&lock);

    while (head == NULL)
    {
      pthread_cond_wait(&has_product, &lock);

#if 1
      if (head == NULL)
      {
	printf("[C%02d] Spurious wake up.\n", id);
      }
#endif
    }

    mp = head;
    head = mp->next;

    pthread_mutex_unlock(&lock);

    printf("[C%02d] %d\n", id, mp->num);

    free(mp);

    sleep(rand() % 5);
  }
}

//--------------------------------------------------------------------
// Producer thread
//--------------------------------------------------------------------
void *producer(void *p)
{
  int id = (int) p;

  struct msg *mp;

  for (;;)
  {
    mp = malloc(sizeof(struct msg));
    mp->num = rand() % 1000 + 1;

    printf("[P%02d] %d\n", id, mp->num);

    pthread_mutex_lock(&lock);

    mp->next = head;
    head = mp;

    pthread_mutex_unlock(&lock);

    //pthread_cond_signal(&has_product);
    pthread_cond_broadcast(&has_product);

    sleep(rand() % 5);
  }
}

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char *argv[])
{
  //pthread_t pid, cid;
  pthread_t threads[THREADS_NUM];

  srand(time(NULL));

  //------------------------------------------------------------------
  // Create threads
  //------------------------------------------------------------------
  int i;

  for (i = 0; i < THREADS_NUM; i++)
  {
    if (i % 5 == 0)
    {
      //--------------------------------------------------------------
      // Create producer thread
      //--------------------------------------------------------------
      pthread_create(&threads[i], NULL, producer, (void *) i);
    }
    else
    {
      //--------------------------------------------------------------
      // Create consumer thread
      //--------------------------------------------------------------
      pthread_create(&threads[i], NULL, consumer, (void *) i);
    }
  }

  //------------------------------------------------------------------
  // Wait for every threads
  //------------------------------------------------------------------
  for (i = 0; i < THREADS_NUM; i++)
  {
    pthread_join(threads[i], NULL);
  }

  //------------------------------------------------------------------
  // Destroy mutex & condition variable
  //------------------------------------------------------------------
  pthread_cond_destroy(&has_product);
  pthread_mutex_destroy(&lock);

  //------------------------------------------------------------------
  // Termination
  //------------------------------------------------------------------
  return 0;
}

// vim:tabstop=8
