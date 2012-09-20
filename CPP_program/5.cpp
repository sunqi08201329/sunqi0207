#include <iostream>
using namespace std;
int main(int argc, const char *argv[])
{
	int age;
	string name;
	cin >> name >> age;
	if(age < 0)
		cerr << "\nError, hahh";
	else
		cout << "\n" << name << " has " << age << " years old." << endl;
	return 0;
}
