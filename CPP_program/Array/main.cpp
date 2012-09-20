#include "class.h" 
int main(int argc, const char *argv[])
{
	Array<int> a;
	a.resize(10);
	//a.elements[0]=1;
	
	for (int i=0; i < 10; i++)
		        a[i] = i; 
	cout << "sizeof(a) = "<< sizeof(a) << endl;
	cout << a.length()<<  endl;
	//cout << a.elements[0];
	return 0;
}
