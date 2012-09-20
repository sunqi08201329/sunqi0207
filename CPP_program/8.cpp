#include <iostream>
#include <fstream>
using namespace std;

int main(int argc, const char *argv[])
{
	char x;
	ifstream inf;
	inf.open("6.cpp");
	if(!inf)
		cerr << "error\n";
	while(inf >> x){
			cout << x ;
	}
	inf.close();
	return 0;
}
