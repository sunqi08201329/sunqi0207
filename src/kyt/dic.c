#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WORD_LEN	30
#define EX_LEN		1024
#define PART_FILE_SIZE 10000
typedef struct node{
	char word[WORD_LEN];
	char explain[EX_LEN];
	long fp_pos;
	struct node *next;
}*pword, WORD;

int menu(void)
{
	int choice;
	puts("\nPlease make a choice:\n1.search for a word\n2.add a word\n9.quit");
	scanf("%d", &choice);
	getchar();
	return choice;
}

pword malloc_r(size_t t)
{
	pword new = malloc(t);
	if(new == NULL){
		perror("malloc.");
		exit(EXIT_FAILURE);
	}
	return new;
}

int modified_word(char *word)
{
	char *p;
	p = word;
	int i = 0;
	while(*p){
		if((*p >= 'a'&& *p <= 'z') || (*p >= 'A' && *p <= 'Z')){
			word[i] = *p;
			i++;
		}
		p++;
	}
	word[i++] = '\n';
	word[i] = '\0';
	return i;
}

pword part_file_word_link(FILE *fp, pword *head, int flag)
{
	pword pw = *head, new = *head, post;
	int cnt = 0;
	char *ret_v;
	char wbuf[WORD_LEN];
	//char ebuf[EX_LEN];

	while((ret_v = fgets(wbuf, WORD_LEN - 1, fp)) != NULL && cnt < PART_FILE_SIZE)
	{
		if(flag == 0){
			new = malloc_r(sizeof(WORD));
			new->next = NULL;
		
			if(*head != NULL){
				pw->next = new;
				pw = new;
				
			}else{
				pw = *head = new;
			}
		}
		strcpy(new->word, ret_v);
		fgets(new->explain, EX_LEN - 1, fp);
		//strcpy(new->explain, ebuf);
		new->fp_pos = ftell(fp);
		if(flag != 0){
			new = new->next;
		}
		cnt += 2;
	}
	if(cnt != PART_FILE_SIZE){
		post = new->next;
		new->next = NULL;
		while(post != NULL){
			new = post;
			post = post->next;
			free(new);
		}
	}
	return *head;

}

void print_ex(pword cur)
{
	char * ex = cur->explain;
	ex += 6;
	char buf[EX_LEN];
	strcpy(buf, ex);
	ex = buf;
	ex = strtok(ex, "@");
	int i = 0;
	cur->word[strlen(cur->word) - 1] = '\0';
	printf("%s on %ld\n", cur->word + 1, cur->fp_pos);
	while(ex != NULL)
	{
		printf("%d.%s\n", ++i, ex);
		ex = strtok(NULL, "@");
	}
}


pword search(char *word, pword *head)
{
	pword move;
	int cnt = 0;
	FILE *fp = fopen("dict.txt", "r+");
	if(fp == NULL)
	{
		perror("open");
		exit(0);
	}
	
	move = *head = part_file_word_link(fp, head, 0);
	
	while(move != NULL)
	{
		if(move->word[0] == '#'){
			if(strcmp(word, (move->word) + 1) <= 0)
			{
				//print_ex(move);
				return move;
			}
		}
		cnt += 2;
		move = move->next;
		if(move == NULL){
			if(cnt != PART_FILE_SIZE)
				break;
			cnt = 0;
			move = *head = part_file_word_link(fp, head, 1);
		}
	}

	fclose(fp);
	return move;
}
void search_for_word(pword *head)
{
	char word[WORD_LEN];
	pword move;
	fprintf(stdout, "Please input the word:");
	fgets(word, WORD_LEN-1, stdin);

	modified_word(word);

	move = search(word, head);
	while(move != NULL){
		if(!strcmp(word, move->word + 1)){
			printf("word is include:\n");
			print_ex(move);
			return;
		}
		else if(!strncmp(word, move->word + 1, strlen(word) - 1)){
			printf("similar word:\n");
			print_ex(move);
		}
		else
			return;
		move = move->next;
	}
}
void destroy_link(pword *head)
{
    pword move = *head;
    while(move != NULL){
        *head = move->next;
        free(move);
        move = *head;
    }
}

int main(int argc, const char *argv[])
{
	int choice;
	pword head = NULL;
	while(1)
	{
		choice = menu();
		if(choice == 1)
		{
			while(1){
				search_for_word(&head);
				destroy_link(&head);
			}
		}
		else if(choice == 2)
		{
	//		add_word();
		}
		else if(choice == 9)
		{
			break;
		}
	}
	return 0;
}
