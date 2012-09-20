#include <iostream>
using namespace std;

int main(int argc, const char *argv[])
{
	char buf[50];
	cout << "in:\n";
	cin.getline(buf,20);
	cout << cin.gcount() << endl;
	cout << "out:\n";
	cout.write(buf,20);

	return 0;
}
