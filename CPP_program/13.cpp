#include <iostream>
using namespace std;

void first_bigger(int * &p, int key)
{
	while(*p <= key)
		p++;
}
int main(int argc, const char *argv[])
{
	int numbers[14] = {0,21 ,213, 2, 44, 42, 6743, 3, 10};
	int *result = numbers;
	int i;
	first_bigger(result, 60);
	cout << "result is:" << *result << endl;
	for (i = 0; i < 15; i++) 
	{
		cout<< numbers[i] << endl;//in array arrand uninit members are init to 0
	}
	return 0;
}
