#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WORD_LEN	30
#define EX_LEN		1024
#define EX_NUM		10
#define PART_FILE_SIZE 10000
#define INSERT_WORD_NUM 128
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

void fopen_r(FILE *fp)
{
	if(fp == NULL)
	{
		perror("open");
		exit(0);
	}
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

long part_file_word_link(FILE *fp, pword *head)
{
	pword pw = *head, new = *head;
	int cnt = 0;
	char *ret_v;
	char wbuf[WORD_LEN];
	int pos = ftell(fp);

	while((ret_v = fgets(wbuf, WORD_LEN - 1, fp)) != NULL && cnt < PART_FILE_SIZE)
	{
		new = malloc_r(sizeof(WORD));
		new->next = NULL;
			
		if(*head != NULL){
			pw->next = new;
			pw = new;
			
		}else{
			pw = *head = new;
		}
		strcpy(new->word, ret_v);
		fgets(new->explain, EX_LEN - 1, fp);
		if(new == *head){
			new->fp_pos = pos;
		}
		pos = ftell(fp);
		if(new != *head){
			new->fp_pos = pos;
		}
		cnt += 2;
	}
	return pos;

}
long part_file_copy(FILE *fp, pword *head)
{
	pword pw = *head, new = *head;
	int cnt = 0;
	char *ret_v;
	char wbuf[WORD_LEN];

	int pos = ftell(fp);
	while((ret_v = fgets(wbuf, WORD_LEN - 1, fp)) != NULL && cnt < PART_FILE_SIZE)
	{
		strcpy(new->word, ret_v);
		fgets(new->explain, EX_LEN - 1, fp);
		new->fp_pos = ftell(fp);
		new = new->next;
		if(new == *head){
			new->fp_pos = pos;
		}
		pos = ftell(fp);
		if(new != *head){
			new->fp_pos = pos;
		}
		cnt += 2;
	}
	if(cnt != PART_FILE_SIZE){
		pw = new->next;
		new->next = NULL;
		while(pw != NULL){
			new = pw;
			pw = pw->next;
			free(new);
		}
	}
	return pos;

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
	fopen_r(fp);

	part_file_word_link(fp, head);
	move = *head; 
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
			part_file_word_link(fp, head);
			move = *head; 
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


pword make_a_node(pword ihead)
{
	pword new;
	new = malloc_r(sizeof(WORD));
	new->next = NULL;
	if(ihead == NULL)
		 ihead = new;
	else{
		new->next = ihead;
		ihead = new;
	}
	return ihead;
}

pword make_new_link(pword ihead, pword *head)
{
	char word[WORD_LEN];
	char explain[EX_NUM][EX_LEN];
	char explains[EX_LEN];
	int i, num = 0;
	pword pre;
	while(1){	
		ihead = make_a_node(ihead);
		pre = search(word, head);
		ihead->fp_pos = pre->fp_pos;

		printf("Please enter a word(input 1 to exit):");
		fgets(word, WORD_LEN - 1, stdin);
		modified_word(word);
		strcpy(word, "#");
		strcpy(ihead->word, word);
		
		printf("Please enter it's explain num:");
		scanf("%d", &num);
		getchar();
		i = num;
		strcpy(explains, "trans:");
		while(num > 0){
			printf("Please enter it's explain num%d:",i - num + 1);
			fgets(explain[num - 1], EX_LEN - 1, stdin);


			if(num == 1){
				strcat(explains, explain[num - 1]);
			}else{
				explain[num - 1][strlen(explain[num - 1]) - 1] = '@';
				strcat(explains, explain[num - 1]);
			}
			num--;	
		}
	}
	return ihead;
	
}

pword sort_new_link(pword ihead)
{
	pword move, first, pre, cur;
	move = ihead;
	while(move->next != NULL){
		first = ihead;
		while(first != move->next){
			if(move->fp_pos < move->next->fp_pos)
				break;
			if(move->next->fp_pos < first->fp_pos){
				cur = move->next;
				move->next = move->next->next;
				if(first == ihead){
					cur->next = ihead;
					ihead = cur;
				}else{
					cur->next = first;
					pre->next = cur;
				}
			}
			pre = first;
			first = first->next;
		}
		move = move->next;
	}
	return ihead;
}

int cnt_size_block(pword ihead, long size[], FILE *fp)
{
	pword move = ihead;
	int i = 0;
	long end;
	while(move->next != NULL){
		size[i] = move->next->fp_pos - move->fp_pos;
		i++;
		move = move->next;
	}
	fseek(fp, 0, SEEK_END);
	end = ftell(fp);
	size[i] = end - move->fp_pos;
	return i;
}

void move_to_temfile(pword ihead, FILE *fp, FILE *fp_temp)
{
	char w[WORD_LEN];
	char ex[EX_LEN];
	fseek(fp, ihead->fp_pos, SEEK_SET);
	while(fgets(w, strlen(w), fp) != NULL){
		fputs(w, fp_temp);
		fgets(ex, strlen(ex), fp);
		fputs(ex, fp_temp);
	}
}

pword insert_to_dic(pword *head)
{
	pword ihead = NULL, move;
	char w[WORD_LEN];
	char ex[EX_LEN];
	long size[INSERT_WORD_NUM], sum = 0;
	int insert_num, i = 0;
	ihead = make_new_link(ihead, head);
	ihead = sort_new_link(ihead);
	move = ihead;
	FILE *fp = fopen("dict.txt", "r+");
	fopen_r(fp);
	FILE *fp_temp = fopen("fp_temp.txt", "w");
	fopen_r(fp_temp);
	insert_num = cnt_size_block(ihead, size, fp);
	move_to_temfile(ihead, fp, fp_temp);
	fseek(fp, ihead->fp_pos, SEEK_SET);
	while(insert_num > i){
		sum += size[i];
		fwrite(move->word, 1, strlen(move->word), fp);
		fwrite(move->explain, 1, strlen(move->explain), fp);
		while(ftell(fp_temp) < sum){
			fread(w, 1, 1, fp_temp); 
			fwrite(w, 1, 1, fp);
			fread(ex, 1, 1, fp_temp); 
			fwrite(ex, 1, 1, fp);
		}
		i++;
		move = move->next;
	}
	fclose(fp_temp);
	fclose(fp);
	return ihead;
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
	pword ihead = NULL;
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
				ihead = insert_to_dic(&head); 
				destroy_link(&ihead);
		}
		else if(choice == 9)
		{
			break;
		}
	}
	return 0;
}
