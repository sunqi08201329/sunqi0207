#include <iostream>
using namespace std;
int main(int argc, const char *argv[])
{
	//char a;
	//char buf[22];
	//cout << "please input a char:";
	//cin.get(a);
	//cout << a << endl;
	//cout << "\ninput a string:";
	//cin.ignore(5);
	//cin.getline(buf, 10);
	//cout << "\n" << buf << endl;

	char p;
	while(cin.peek() != '\n')
		cout << (p = cin.get());
	cout << endl;
	
	return 0;
}
