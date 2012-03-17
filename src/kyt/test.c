#include <stdio.h>
#include <string.h>

int main(int argc, const char *argv[])
{
	FILE *fp = fopen("test.txt","r+");
	char a[1024];
	long pos = 0;
	char words[1024] = "sunqiaaaaaaaaaaaaaaaaaaaaaaaa\n";
	//rewind(fp);
	fgets(a, 1024, fp);
	//fgets(a, 1024, fp);
	pos = ftell(fp);
	//fseek(fp, pos-1 , SEEK_SET);
	
	fwrite("\n", 1,1, fp);
	fseek(fp, pos , SEEK_SET);
	fputs(words,fp);
	fclose(fp);
	return 0;
}
