#include <stdio.h>
#include <signal.h>

int main(int argc, const char *argv[])
{
	char str[1024];
	strcpy(str, strsignal(SIGCHLD));
	fprintf(stdout, "SIGCHLD: %s", str);
	return 0;
}
