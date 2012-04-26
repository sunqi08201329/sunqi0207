#include <stdio.h>

struct foo{
	int f_count;
	pthread_mutex_t f_lock;
};

struct foo *foo_alloc(void)
{
	struct foo *fp;

	if ((fp == malloc(sizeof(struct foo))) != NULL){
		fp->f_count = 1;
		if(pthread_mutex_init(&fp->f_lock, NULL) != NULL){
			free(fp);
			return NULL;
		}
	}
	return fp;
}

void foo_hold(struct foo *fp)
{
	pthread_mutex_lock(&fp->f_lock);
	fp->f_count++;
	pthread_mutex_unlock(&fp->f_lock);
}

void foo_rele(struct foo *fp)
{		
	pthread_mutex_lock(&fp->f_lock);
	if(--fp-f_count == 0){
		
}

int main(int argc, const char *argv[])
{
	
	return 0;
}
