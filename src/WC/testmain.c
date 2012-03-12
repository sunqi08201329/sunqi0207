#include <stdio.h>
#include <stdlib.h>
#include "queue.h"
#include "memory.h"

int main(int argc, const char *argv[])
{
	char ch;
	char *p;
	Queue *queue = malloc_r(sizeof(Queue));
	queue_init(queue);	
	while((ch = getchar() != '\n')){
		p = malloc(sizeof(char));
		p = &ch;
		inqueue(queue, p);			
	}
	while(!is_empty(queue)){
		p =	dequeue	(queue);
		putchar(*p);
	}
	return 0;
}
