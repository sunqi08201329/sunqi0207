#include <iostream>
#include <stdlib.h>

using namespace std;

const int Defaultsize = 100;

template <class type>
class Array{
	type *elements;
	int Arraysize;
	void getArray();
public:
	Array(int Size = Defaultsize);
	Array(const Array<type>&x);
	~Array(){delete []elements;}
	/*Array<type> &operator = (const Array<type> &A);*/
	type &operator[](int i);
	int length() const{return Arraysize;}
	void resize(int size);
};

template <class type>
void Array<type>::getArray()
{
	elements = new type[Arraysize];
	if(elements == NULL){
		Arraysize = 0;
		cerr << "malloc memory failed\n";
		return ;
	}
}

template <class type>
Array<type>::Array(int sz)
{
	if(sz < 0){
		Arraysize = 0;
		cerr << "Array(int sz) sz negative\n";
		return;
	}
	Arraysize = sz;
	getArray();
}

template <class type>
Array<type>::Array(const Array<type> &x)
{
	int n = x.Arraysize;
	Arraysize = n;
	elements = new type[n];
	if(elements == NULL){
		Arraysize = 0;
		cerr << "malloc memory failed.\n";
		return;
	}
	type *srcptr = x.elements;
	type *destptr = elements;
	while(n--)
		*destptr++ = *srcptr++;
}

template <class type>
type &Array<type>::operator [] (int i)
{
	if(i < 0 || i > Arraysize){
		cerr << "array out to bound\n";
		return NULL;
	}
	return elements[i];
}

template <class type>
void Array<type>::resize(int sz)
{
	if(sz >= 0 && sz != Arraysize){
		type* newarray = new type[sz];
		if(newarray == NULL){
			cerr << "malloc failed\n";
			return;
		}
	
		int n = (sz <= Arraysize) ? sz : Arraysize;
		type * srcptr = elements;
		type * destptr = newarray;
		while(n--)
			*destptr++ = *srcptr++;
		elements = newarray;
		Arraysize = sz;
	}
}
