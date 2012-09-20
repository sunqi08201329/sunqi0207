#include "LinkStack.h"
#include <cstdlib>

int main()
{
	cout << "please input() and end with 0\n";
	LinkStack<char> small;
	char a;
	do{
		cin>>a;
		switch(a){
			case '(': small.Push(a);break;
			case ')':
				  if(!small.IsEmpty())
					  small.Pop();
				  break;
		}
		if(small.IsEmpty()){
			cout << "Wrong!\n";
			exit(0);
			break;
		}
	} while(a != '0');
	if(small.IsEmpty())
		cout << "OK!\n";
	else
		cout << "Wrong!\n";
	return 0;
}

