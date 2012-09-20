#include <iostream>
using namespace std;

template <class T>
class LinkStackNode{
public:
	T data;
	LinkStackNode<T> * link;
	LinkStackNode(T& value):link(NULL),data(value){}
};
