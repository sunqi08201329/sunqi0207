#include <stdio.h>

#define N 10
#define M 20

int main(int argc, const char *argv[])
{
	char **name;
	process(name);
	return 0;
}
void process(char **name)
{
	name = (char**)malloc(sizeof(char *) * N);
	for (i = 0; i < N; i++) 
	{
		name[i] = malloc(sizeof(char) * M);
		
	}
}
