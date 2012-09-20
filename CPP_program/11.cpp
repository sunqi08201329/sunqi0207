#include <iostream>
#include <vector>
#include <deque>
using namespace std;

int main(int argc, const char *argv[])
{
	//vector<int> v;
	deque<int> v;
	int i;
	for (i = 0; i < 100000; i++) 
	{
		v.insert(v.end(), i);
	}
	return 0;
}
