#ifndef _QUEUE_H_
#define _QUEUE_H_

#include <stdio.h>
#include <stdbool.h>

typedef struct node{
	void *data;
	struct node *next;
}node;

typedef struct queue{
	struct node *head;
	struct node *tail;
}Queue;

extern void queue_init(Queue *queue);
extern void queue_destroy(Queue *queue);
extern void inqueue(Queue *queue, void *n);
extern void * dequeue(Queue *queue);
extern bool is_empty(Queue *queue);
extern void *queue_find(Queue *queue, void *data, bool (*compare)(const void *first, const void *second));

#endif //_QUEUE_H_
