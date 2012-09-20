#include <iostream>
#include <stdexcept>
#include <vector>
using namespace std;
int main ()
{
	vector<int> myvector (10);   // 10 zero-initialized ints
	unsigned int i;
	// assign some values:
	for (i=0; i<myvector.size(); i++)
		myvector.at(i)=i;
	cout << "myvector contains:";
	try{
		for (i=0; i<myvector.size() + 1; i++)
			cout << " " << myvector.at(i);
	} catch(out_of_range){
		cerr << "access array out of range!" << endl;
	}
	
	return 0;
}
