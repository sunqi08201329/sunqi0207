#include <iostream>
using namespace std;

namespace shell{
	int a;
	char b;
}

int main()
{
	shell::a = 10;
	cout << "shell::a=" << shell::a << endl;
}
