#include <stdio.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>

#define MAX_SIZE  1024
#define NAME_LEN 8
#define BUFF_MAX  1024
#define PERSON_NUM_MAX 100

//typedef void *(delete_By *)(void *);
struct message{
	int ID;
	char NAME[NAME_LEN];
	double CHGRADE, MATHGRADE, AVG;
};
typedef struct link{
	struct message stu_mes;
	struct link *next;
}*stu_link, STU_LINK;

void mylog(void *fp)
{
	time_t t = time(NULL);
	struct tm *T = localtime(&t);	
	FILE *log;
	if(fp == NULL){
		log = fopen("log.txt", "a");
		fprintf(log, "%04d/%02d/%02d  %02d:%02d:%02d  %s ", 
		T->tm_year + 1900,T->tm_mon + 1, T->tm_mday, T->tm_hour, T->tm_min,
		T->tm_sec, T->tm_zone);
		fprintf(log, "  ERROR: errno %d %p %s\n", errno, fp, (char*)strerror(errno));
		fclose(log);
	}

}
stu_link makeLink(int id, char *name, double chgrade, double mathgrade)
{
	stu_link one_link = malloc(sizeof(STU_LINK));
	
	mylog(one_link);

	if(one_link == NULL){
		perror("malloc fail");
		exit(EXIT_FAILURE);
	}

	one_link->next = NULL;
	(one_link->stu_mes).ID = id;
	strcpy((one_link->stu_mes).NAME, name);
	(one_link->stu_mes).CHGRADE = chgrade;
	(one_link->stu_mes).MATHGRADE = mathgrade;
	(one_link->stu_mes).AVG = (chgrade + mathgrade) / 2;
	return one_link;

}
stu_link copyLink(stu_link dest,stu_link src)
{
	dest = malloc(sizeof(STU_LINK));
	

	if(dest == NULL){
		perror("malloc fail");
		exit(EXIT_FAILURE);
	}

	dest->next = NULL; 
	(dest->stu_mes).ID = (src->stu_mes).ID  ;
	strcpy((dest->stu_mes).NAME, (src->stu_mes).NAME); 
	(dest->stu_mes).CHGRADE = (src->stu_mes).CHGRADE ;
	(dest->stu_mes).MATHGRADE = (src->stu_mes).MATHGRADE ;
	(dest->stu_mes).AVG = (src->stu_mes).AVG ;

	return dest;

}
stu_link load_stu_message(const char *filename, stu_link head)
{		
	char buff[BUFF_MAX];
	FILE *student_mes = fopen(filename, "r");
	int id; 
	char name[NAME_LEN]; 
	double chgrade, mathgrade;
	
	stu_link move, new;
	new = move = head;

	mylog(student_mes);

	if(student_mes == NULL){
		perror("opne file fail!");
	 	exit(EXIT_FAILURE);
	}
	while(fgets(buff, sizeof(buff), student_mes) != NULL){
		sscanf(buff, "%d%s%lf%lf", &id, name, &chgrade, &mathgrade);
		if(head == NULL){
			head = move = new = makeLink(id, name, chgrade, mathgrade);
		}else{
			new = makeLink(id, name, chgrade, mathgrade);
			move->next = new;
			move = new;
		}
	}
	fclose(student_mes);
	return head;
			
}
void show_stu_message(stu_link head)
{
	stu_link move = head;
	int seq = 1;
	if(head == NULL){
		printf("there is no datas!you can choice to insert some!\n");
		return;
	}
	printf("%-4s%-8s%-8s%-8s%-8s%-8s\n", "seq", "ID", "NAME", "CHINESE", "MATH", "AVERAGE");
	printf("--------------------------------------------------\n");
	while(move != NULL){
		printf("%-4d%-8d%-8s%-8.1lf%-8.1lf%-8.1lf\n", seq, (move->stu_mes).ID, 
		(move->stu_mes).NAME,(move->stu_mes).CHGRADE, (move->stu_mes).MATHGRADE, 
		(move->stu_mes).AVG);
		seq++;
		move = move->next;
	}
	printf("--------------------------------------------------\n");
}
void insert_stu_message(stu_link head, const char *filename)
{
	stu_link move, new;
	move = head;
	int id_num;
	FILE *stu_mes_file = fopen(filename, "a");
	if(stu_mes_file == NULL){
		perror("open file fail");
		exit(EXIT_FAILURE);
	}
	if(head == NULL)
		id_num = 0;
	else{	
		while(move->next != NULL){
			move = move->next;
		}
		id_num = (move->stu_mes).ID;
	}

	new = malloc(sizeof(STU_LINK));
	if(new == NULL){
		perror("malloc fail!");
		exit(EXIT_FAILURE);
	}

	id_num ++;
	(new->stu_mes).ID = id_num;

	printf("please input student no.%d' name:", id_num);
	scanf("%s", (new->stu_mes).NAME);
	printf("please input student no.%d' chinese grade:", id_num);
	scanf("%lf", &(new->stu_mes).CHGRADE); 
	printf("please input student no.%d' math grade:", id_num);
	scanf("%lf", &(new->stu_mes).MATHGRADE);

	(new->stu_mes).AVG = ((new->stu_mes).CHGRADE + (new->stu_mes).MATHGRADE) / 2;
	fprintf(stu_mes_file, "%d %s %.1lf %.1lf\n", id_num, (new->stu_mes).NAME,(new->stu_mes).CHGRADE, (new->stu_mes).MATHGRADE);

	new->next = NULL;
	move->next = new;

	fclose(stu_mes_file);
}
stu_link sort_by_average(stu_link head)
{
	stu_link sort_head, move, new, cur;
	sort_head = cur = new = NULL;
	move = head;
	while(move != NULL){
		if(sort_head != NULL){
			new = copyLink(new, move);
			cur = sort_head;
			if(((new->stu_mes).AVG - (sort_head->stu_mes).AVG) <= 0.000001){
			    while(cur->next != NULL){
				    //printf("%p\n", cur->next);
				if(((new->stu_mes).AVG - (cur->next->stu_mes).AVG) > 0.000001){
					new->next = cur->next ;
					cur->next = new;
					break;
				}
				cur = cur->next;
			    }
				if(cur->next == NULL){
					cur->next = new;
				}
			}else{
				new->next = sort_head;
				sort_head = new;
			}
		}else{
			sort_head = new = cur = copyLink(sort_head,move);
		}	
		move = move->next;
	}
	return sort_head;
}
stu_link delete_stu_mes_by_id(stu_link head,int id)
{	
	stu_link move = head, post;
	int flag = 0;

	while(move != NULL){
		if((head->stu_mes).ID == id){
			flag = 1;
			head = head->next;
			free(move);
			move = head;
			break;
		}else if(move->next != NULL){
			if((move->next->stu_mes).ID == id){
				flag = 2;
				post = move->next->next;
				free(move->next);
				move->next = post;
				break;
			}
		}
		move = move->next;
	}
	if(flag == 0){
		printf("No such ID\n");
		return  head;
	}
	
	while(move != NULL && flag){
		if(flag == 1)
			(move->stu_mes).ID--;
		else if((flag == 2) && (move->next != NULL))
			(move->next->stu_mes).ID--;
		move = move->next;
	}
	return head;
}
stu_link delete_stu_mes_by_name(stu_link head,char *name)
{	
	stu_link move = head, post;
	int flag = 0;

	while(move != NULL){
		if(!strcmp((head->stu_mes).NAME, name)){
			flag = 1;
			head = head->next;
			free(move);
			move = head;
			break;
		}else if(move->next != NULL){
			if(!strcmp((move->next->stu_mes).NAME, name)){
				flag = 2;
				post = move->next->next;
				free(move->next);
				move->next = post;
				break;
			}
		}
		move = move->next;
	}
	if(move == NULL){
		printf("No such name\n");
		return  head;
	}
	while(move != NULL && flag){
		if(flag == 1)
			(move->stu_mes).ID--;
		else if((flag == 2) && (move->next != NULL))
			(move->next->stu_mes).ID--;
		move = move->next;
	}
	return head;
}
void updata_to_file(stu_link head, const char *filename)
{
	FILE *stu_mes_file = fopen(filename, "w");
	stu_link move = head;
	while(move != NULL){
		fprintf(stu_mes_file, "%d %s %.1lf %.1lf\n", (move->stu_mes).ID, 
		(move->stu_mes).NAME, (move->stu_mes).CHGRADE, (move->stu_mes).MATHGRADE);
		move = move->next;
	}
	fclose(stu_mes_file);
}
void destroy_link(stu_link head)
{
	stu_link move = head;
	while(move != NULL){
		head = move->next;
		free(move);
		move = head;
		}
}
void show_manu()
{
	printf("Please select the option:\n1.Display all student's info\n2.Sort by average\n3.Insert a nre info\n4.Delete a record\n5.Quit\n");
	printf("Please input your choice:");
}
void show_del_manu()
{
	printf("1.Delete by ID\n2.Delete by name\n3.Exit\n");
	printf("Please input your choice:");
}
int main(int argc, const char *argv[])
{
	stu_link head = NULL;
	stu_link sort_head = NULL;
	head = load_stu_message(argv[1], head);
	//show_stu_message(head);
	//sort_head = sort_by_average(head);
	//show_stu_message(sort_head);
	//insert_stu_message(head, argv[1]);
	//show_stu_message(head);
	int no, del_id;
	char del_name[NAME_LEN];
	while(1){
		show_manu();
		scanf("%d", &no);
		switch(no){
			case 1:
				show_stu_message(head);
				continue;
			case 2:
				sort_head = sort_by_average(head);
				show_stu_message(sort_head);
				continue;
			case 3:
				insert_stu_message(head, argv[1]);
				continue;
			case 4:{
			    while(no != 3){
				show_del_manu();
				scanf("%d", &no);
				switch(no){
				case 1: 
					printf("Your should choice the id exist:");
					scanf("%d", &del_id);
					head = delete_stu_mes_by_id(head,del_id); 
					show_stu_message(head);
					updata_to_file(head, argv[1]);
					continue;
				case 2:
					printf("Your should choice the name exist:");
					scanf("%s", del_name);
					head = delete_stu_mes_by_name(head,del_name); 
					show_stu_message(head);
					updata_to_file(head, argv[1]);
					continue;
				case 3:
					break;
				default:
					printf("please input 1-3\n");
					continue;
				}
			}
				continue;
			}
			case 5:
				break;
			       //exit(EXIT_SUCCESS);
			default:
				printf("please input 1-5\n");
				continue;
	}
	destroy_link(head);
	head = NULL;
	return 0;
	}
}
