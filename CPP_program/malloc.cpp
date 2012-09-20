#include <stdlib.h>
#include <unistd.h>
int main(int argc, const char *argv[])
{
	while(1){
		malloc(65536);
		new int[65536];
		sleep(1);
	}
	return 0;
}
