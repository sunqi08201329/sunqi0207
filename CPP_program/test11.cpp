#include<iostream>
using namespace std;
int main(int argv,char * argc[])
{
	for(int i=0;i<19;i++)
	{
		static char cc[19] = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
		//19个空格
		static const int j = 19 / 2;   //j值为9
		static int count = 0;          //count为离中间元素的距离
		if( i < ( 19 / 2 + 1)) 
		{
			cc[j - count] = '*';
			cc[j + count] = '*';
			cout << cc << endl;
			count++;
		} 
		else 
		{
			count--;
			cc[j - count] = ' ';
			cc[j + count] = ' ';
			cout << cc << endl;
		}
	}
	return 0;
}

