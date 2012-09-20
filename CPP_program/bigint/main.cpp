#include <iostream>
#include <memory>
#include <string.h>
using namespace std;

int * multi(int *num1, int size1, int * num2, int size2)
{
	int size = size1 + size2;
	int *ret = new int[size];
	int i = 0, j = 0, k = 0;
	memset(ret, 0, sizeof(int) * size);
	
	for (i = 0; i < size1; i++) 
	{
		k = i;
		for (i = 0; i < size2; i++) 
		{
			ret[k++] += num1[i] * num2[j];
		}
	}
	for (i = 0; i < size; i++) 
	{
		if(ret[i] > 9){
			ret[i+1] += ret[i] / 10;
			ret[i] = ret[i] % 10;
		}
	}
	return ret;
}
int main(int argc, const char *argv[])
{
	int num1[] = {1,2,3,4,5,6,7,8,9,1,1,1,1,1};
	int num2[] = {1,1,1,2,2,2,3,3,3,4,4,4,5,5};
	int *ret = multi(num1, sizeof(num1)/sizeof(int), num2, sizeof(num2)/sizeof(int));
	for (int i = 0; i < sizeof(num1)/sizeof(int) + sizeof(num2)/sizeof(int); i++) 
	{
		cout << ret[i];
	}
	delete [] ret;
	return 0;
}
