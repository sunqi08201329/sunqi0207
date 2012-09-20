#include <iostream>
using namespace std;

class a
{
public:
	virtual const char *saywhat(void)=0;
};
class b:public a
{
public:
	virtual const char *saywhat(void){return "MOOm";}
};
int main(int argc, const char *argv[])
{
	b x;
	cout << sizeof(x) << endl;
	return 0;
}
