// http://learn.akae.cn/media/ch35s03.html#id2895424
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

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
  struct msg *mp;

  for (;;)
  {
    pthread_mutex_lock(&lock);

    while (head == NULL)
      pthread_cond_wait(&has_product, &lock);

    mp = head;
    head = mp->next;

    pthread_mutex_unlock(&lock);

    printf("Consume %d\n", mp->num);

    free(mp);

    sleep(rand() % 5);
  }
}

//--------------------------------------------------------------------
// Producer thread
//--------------------------------------------------------------------
void *producer(void *p)
{
  struct msg *mp;

  for (;;)
  {
    mp = malloc(sizeof(struct msg));
    mp->num = rand() % 1000 + 1;

    printf("Produce %d\n", mp->num);

    pthread_mutex_lock(&lock);

    mp->next = head;
    head = mp;

    pthread_mutex_unlock(&lock);

    pthread_cond_signal(&has_product);

    sleep(rand() % 5);
  }
}

//--------------------------------------------------------------------
// Main function
//--------------------------------------------------------------------
int main(int argc, char *argv[])
{
  pthread_t pid, cid;

  srand(time(NULL));

  pthread_create(&pid, NULL, producer, NULL);
  pthread_create(&cid, NULL, consumer, NULL);

  pthread_join(pid, NULL);
  pthread_join(cid, NULL);

  return 0;
}

// vim:tabstop=8
