#include <iostream>
#include <string.h>
using namespace std;

char *first_letter(char *arr, int len)
{
	char *h;
	char     *l;
	char temp;
	h = arr;
	l = arr + len - 2;
	while(h == l){
		if(*h == ' '){
			if(*l != ' '){
				temp = *h;
				*h = *l;
				*l = temp;
				cout<<*l<<endl;
			}else{
				l--;
				cout<<*l<<endl;
			}
		}
		else
			h++;
	}
	arr[len - 1] = '\0';
	return arr;

}

int main(int argc, const char *argv[])
{
	char arr[100] = "asdasd adsad asd dsadasd                     ";
	first_letter(arr, strlen(arr));
	cout<<arr<<endl<<strlen(arr)<<endl;
	cout<<*arr<<endl;
	return 0;
}
