#include<iostream> 
using namespace std;

int gInt=0; 
class book 
{ 
private: 
	int qu; 
	int price; 
	int iIndex; 
public: 
	book() 
	{ 
		iIndex=gInt++; 
		qu=iIndex+1; 
		price=qu*10; 
	} 
	void print() 
	{ 
		cout<<"第"<<iIndex+1<<"个值是"<<price<<endl; 
	} 
}; 
int main() 
{ 
	book s[5]; 
	for(int i=0; i<5; i++) 
	{ 
		s[i].print(); 
	} 
	return 0; 
}
