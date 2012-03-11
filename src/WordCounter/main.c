#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include "queue.h"
#include "memory.h"
#include "debug.h"
#include "IO.h"

#define FILE_LIST	"file_list.txt"

typedef struct file_list_node
{
	char *str;
} file_list_node;

typedef struct word_node
{
	char *str;
	int counter;
} word_node;

void get_random_file_name(char *str, int size)
{
	int i;

	srand(time(NULL));

	for (i = 0; i < size - 1; i ++)
	{
		str[i] = rand() % 26 + 'a';
	}
	str[i] = 0;
}

static void show_result(Queue *word_queue)
{
	FILE *fp;
	word_node *n;
	char buffer[64] = "Word_counter_reslut_";

	get_random_file_name(buffer + strlen(buffer), 6);
	strcat(buffer, ".txt");

	fp = fopen_r(buffer, "w");

	while(! is_empty(word_queue))
	{
		n = dequeue(word_queue);
		printf("%d : %s\n", n->counter, n->str);
		fprintf(fp, "%d:%s\n", n->counter, n->str);

		free(n->str);
		free(n);
	}
	fclose_r(fp);
}

bool word_node_compare(const void *first, const void *second)
{
	word_node *f = (word_node *)first;
	word_node *s = (word_node *)second;

	return ! strcmp(f->str, s->str);
}

static void string_filter(char *str)
{
	int i;

	for (i = 0; str[i]; i ++)
	{
		if (! isalpha(str[i]))
		{
			str[i] = ' ';
		}
	}
}

word_node * make_word_node(const char *str)
{
	word_node * n;

	n = malloc_r(sizeof(word_node));
	n->str = malloc_r(strlen(str) + 1);
	strcpy(n->str, str);
	n->counter = 1;

	return n;
}

file_list_node *make_file_list_node(const char *str)
{
	file_list_node *n;

	n = malloc_r(sizeof(file_list_node));
	n->str = malloc_r(strlen(str) + 1);
	strcpy(n->str, str);

	return n;
}

void get_file_name(Queue *queue, const char *file)
{
	FILE *fp;
	char buffer[128];
	file_list_node *n;

	fp = fopen_r(file, "r");

	while(fgets(buffer, sizeof(buffer), fp) != NULL)
	{
		buffer[strlen(buffer) - 1] = 0;
#ifdef __DEBUG__
		printf("buffer = %s\n", buffer);
#endif
		n = make_file_list_node(buffer);
		inqueue(queue, n);
	}
	fclose_r(fp);
}

void parser_file(Queue *queue, const char *file)
{
	char *p, *ret;
	FILE *fp;
	char buffer[1024];

	fp = fopen_r("test.txt", "r");

	while(fgets(buffer, sizeof(buffer), fp))
	{
		string_filter(buffer);
		
		p = buffer;

		while((ret = strsep(&p, " ")))
		{
			if (strlen(ret) > 3)
			{
				node *sys_node;
				word_node *t;
				word_node *n = make_word_node(ret);

				if ((sys_node = queue_find(queue, n, 
						word_node_compare)) != NULL) {
					t = sys_node->data;
					t->counter ++;
					free(n->str);
					free(n);
				} else {
					inqueue(queue, n);
				}
			}
		}
	}

	fclose_r(fp);
}

int main(int argc, char *argv[]) 
{
	file_list_node *user_node;

	Queue word_queue;
	queue_init(&word_queue);

	Queue file_list_queue;
	queue_init(&file_list_queue);

	get_file_name(&file_list_queue, FILE_LIST);

	while(! is_empty(&file_list_queue)) {
		user_node = dequeue(&file_list_queue);
		parser_file(&word_queue, user_node->str);
		free(user_node->str);
		free(user_node);
	}
	
	show_result(&word_queue);

	queue_destroy(&file_list_queue);
	queue_destroy(&word_queue);

	return 0;
}
