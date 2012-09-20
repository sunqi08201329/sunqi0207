#include "class.h"
#include <iostream>
using namespace std;

template <class T>
class DouList{
	DouListNode<T>* head;
	DouListNode<T>* tail;
	DouListNode<T>* cur;
public:
	DouList();
	~DouList(){};
	bool AddTail(T value);
	bool AddHead(T value);
	void RemoveThis(bool direction);
	void RemoveAll();
	void SetBegin();
	int GetCount();
	void TowardCur();
	void BackCur();
	DouListNode<T>* GetCur();
	DouListNode<T>* GetHead();
	DouListNode<T>* GetTail();
	void InsertAfter(T value);
	bool IsEmpty();
	T GetNext();
	T GetPrior();
};

template <class T>
DouList<T>::DouList() {
	head = tail = new DouListNode<T>;
	cur = NULL;
	head->SetLink(head);
	head->SetPrior(tail);
}
template <class T>
bool DouList<T>::AddTail(T value) {
	DouListNode<T>* add = new DouListNode<T>(value);
	tail->SetLink(add);
	add->SetPrior(tail);
	tail = tail->GetLink();
	tail->SetLink(head);
	head->SetPrior(add);
	if(tail != NULL)
		return true;
	else
		return false;
}
template <class T>
bool DouList<T>::AddHead(T value) {
	DouListNode<T> * add = new DouListNode<T>(value);
	add->SetPrior(head);
	add->SetLink(head->GetLink());
	head->GetLink()->SetLink(add);
	head->SetLink(add);
	if(tail == head)
		tail = head->GetLink();
	if(add != NULL)
		return true;
	else
		return false;
}
template <class T>
void DouList<T>::RemoveThis(bool direction) {
	if(cur == head){
		if(direction == 0)
			cur = cur->GetLink();
		if(direction == 1)
			cur = cur-GetPrior();
	}
	DouListNode<T>* preCur = NULL;
	DouListNode<T>* nextCur = NULL;
	preCur = cur->GetPrior();
	nextCur = cur->GetLink();
	preCur->SetLink(cur->GetLink());
	nextCur->SetPrior(cur->GetPrior());
	if(direction == 0)
		cur = nextCur();
	if(direction == 1)
		cur = preCur;
}
template <class T>
void DouList<T>::RemoveAll() {
	SetBegin();
	int length = GetCount();
	for (int i = 0; i < length; i++) 
	{
		RemoveThis(0);
	}
	cur = head;
}
template <class T>
void DouList<T>::SetBegin() {
	cur = head;
}
template <class T>
int DouList<T>::GetCount() {
	int num = 0;
	DouListNode<T>* here = cur;
	while(cur->GetLink() != here){
		cur = cur->GetLink();
		++num;
	}
	cur = cur->GetLink();
	return num;
}
template <class T>
void DouList<T>::TowardCur() {
	cur = cur->GetLink();
}
template <class T>
void DouList<T>::BackCur() {
	cur = cur->GetPrior();

}
template <class T>
DouListNode<T>* DouList<T>::GetCur() {
	return cur;
}
template <class T>
DouListNode<T>* DouList<T>::GetHead() {
	return head;
}
template <class T>
DouListNode<T>* DouListNode<T>::GetTail() {
	return tail;
}
template <class T>
void DouList<T>::InsertAfter(T value) {
	DouListNode<T>* add = new DouListNode<T>(value);
	DouListNode<T>* nextCur = cur->GetLink();
	cur->SetLink(add);
	add->SetLink(nextCur);
	nextCur->SetPrior(add);
	add->SetPrior(cur);
	if(cur == tail)
		tail = cur->GetLink();
}
template <class T>
bool DouList<T>::IsEmpty() {
	return (head->GetLink() == head);
}
template <class T>
T DouList<T>::GetNext() {
	if(cur == head)
		cur = cur->GetLink();
	T num = cur->GetData;
	cur = cur->GetLink();
	return num;
}
template <class T>
T DouList<T>::GetPrior() {
	if(cur == head)
		cur = cur->GetPrior();
	T num = cur->GetData;
	cur = cur->GetLink();
	return num;
}
