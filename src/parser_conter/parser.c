#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct node{
	char *data;
	int index;
	struct node *next;
}*pwords, words;

void cnt_delte_copies(pwords head)
{
	pwords pos = head->next;
	FILE *fp = fopen("word_note.c", "w");
	if(fp == NULL){
		perror("open file fail!");
		exit(EXIT_FAILURE);
	}
	int cnt;
	pwords move;
	pwords pre;
	while(pos->next != NULL){
		cnt = 1;
		move = pos ->next;
		pre = pos;
		while(move != NULL){
			if(!strcmp(pos->data, move->data)){
				cnt++;
				free(move);
				move = move->next;
				pre->next = move;
			}
			else{
				move = move->next;
				pre = pre->next;
			}

		}
		pos->index = cnt;
		printf("%s:%d\n", pos->data, pos->index);
		fprintf(fp, "%s:%d\n", pos->data, pos->index);

		pos = pos->next;
	}
	fclose(fp);
}
int main(int argc, const char *argv[])
{
	char buff_line[1024];
	char buff_filename[128];
	char *savep, *token, *ret, *filename;
	char *q = "#,.&\"\%\n\t\\/ <>[]*(){};!='-:";
	FILE *fp, *file_list;
	pwords head, move, new;
	head = (pwords)malloc(sizeof(words));
	move = head;
	file_list = fopen(argv[1], "r");
	if(file_list == NULL){
		perror("open file fail!");
		exit(EXIT_FAILURE);
	}
	while((filename = fgets(buff_filename, sizeof(buff_filename), file_list)) != NULL){
		filename[strlen(filename) - 1] = '\0';
		fp = fopen(filename, "r");
		if(fp == NULL){
			perror("open file fail!");
			exit(EXIT_FAILURE);
		}
		printf("%s\n%d\n", filename, strlen(filename));
		while((ret = fgets(buff_line, sizeof(buff_line), fp))!=NULL){	
			while((token = strtok_r(ret, q, &savep)) != NULL){
				ret = NULL;
				new = (pwords)malloc(sizeof(words));
				new->data = (char *)malloc(sizeof(char));
				strcpy(new->data,token);
				move->next = new;
				move = new;
				//printf("%s:%d\n", move->data, move->index);
			}
		}
		fclose(fp);
	}
	fclose(file_list);
	move->next = NULL;
	cnt_delte_copies(head);

	return 0;
}
