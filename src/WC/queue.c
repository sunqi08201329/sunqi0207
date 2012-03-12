#include "queue.h" 
#include "memory.h"

void queue_init(Queue *queue)
{
	queue->head = NULL;
	queue->tail = NULL;
}
void inqueue(Queue *queue, void *user_node)
{
	node *n = malloc_r(sizeof(node));
	n->data = user_node;
	n->next = NULL;

	if(queue->head =NULL){
		queue->head = n;
	}else {
		queue->tail->next = n;
	}
	queue->tail = n;
}
void *dequeue(Queue *queue)
{
	void *data;
	node *n = queue->head;
	data = n->data;
	queue->head = n->next;

	free(n);

	return data;
}
bool is_empty(Queue *queue)
{
	return queue->head == NULL;
}
void *queue_find(Queue *queue, void *data, bool (*compare)(const void *first, const void *second))
{
	node *n = queue->head;

	while(n != NULL){
		if(compare(n->data, data)){
			return n;
		}
		n = n->next;
	}
	return NULL;
}
void queue_destory(Queue *queue)
{
	queue->head = NULL;
	queue->tail = NULL;
}
