#include "class.h"

template <class T> 
class List{
	ListNode<T> *head;
	ListNode<T> *tail;
public:
	List();
	~List(){};
	bool AddTail(T value);
	bool RemoveTail();
	bool InsertAt(int index, T value);
	bool RemoveAt(int index);
	T& GetAt(int index);
	bool IsEmpty();
	int GetCount();
	void RemoveAll();
	ListNode<T> * GetHead();
	ListNode<T> * GetTail();
	void SetTail(ListNode<T>* newtail);
	ListNode<T>* GetNodeAt(int index);
	/*ListNode<T>* GetCur();*/
	/*ListNode<T>* TowardCur();*/
};

template <class T>
List<T>::List(){
	head = tail = new ListNode<T>;
	tail->SetLink(NULL);
}

template <class T>
bool List<T>::AddTail(T value){
	ListNode<T> *add = new ListNode<T>(value);
	tail->SetLink(add);
	tail = tail->GetLink();
	tail->SetLink(NULL);
	if(tail != NULL)
		return true;
	else
		return false;
}

template <class T>
bool List<T>::RemoveTail() {
	return RemoveAt(this->GetCount() -1);
}

template <class T>
bool List<T>::InsertAt(int index, T value) {
	if(index > this->GetCount() - 1 || index < 0){
		cout << "A wrong position!\n"
		return false;
	}
	ListNode<T>* current = head;
	while(index){
		current = current->GetLink();
		--index;
	}
	ListNode<T> * add = new ListNode<T> (value);
	add->SetLink(current->GetLink());
	current->SetLink(add);
	if(current->GetLink() != NULL)
		return true;
	else
		return false;
}

template <class T>
bool List<T>::RemoveAt(int index) {
	if(index > this->GetCount() - 1 || index < 0){
		cout << "A wrong position!\n";
		return false;
	}
	ListNode<T> *cur, *curPre;
	cur = head;
	curPre = cur->GetLink();
	while(index){
		cur = cur->GetLink();
		curPre = curPre->GetLink();
		--index;
	}
	if(tail == curPre)
		tail = cur;
	cur->SetLink(curPre->GetLink());
	if(curPre != NULL)
		return true;
	else
		return false;
}

template <class T>
T& List<T>::GetAt(int index) {
	if(index > this->GetCount() - 1 || index < 0){
		cout << "A wrong position!\n";
		return false;
	}
	ListNode<T>* cur;
	cur = head->GetLink();
	while(index){
		cur = cur->GetLink();
		--index;
	}
	return cur->GetData();
	
}

template <class T>
bool List<T>::IsEmpty() {
	return (head->GetLink() == NULL);
}

template <class T>
int List<T>::GetCount() {
	int count = 0;
	ListNode<T>* current = head;
	while(current != NULL){
		++count;
		current = current->GetLink();
	}
	return count;
}

template <class T>
void List<T>::RemoveAll() {
	ListNode<T> * cur;
	while(head->GetLink()){
		cur = head->GetLink();
		head->SetLink(cur->GetLink());
		delete cur;
	}
	tail = head;
}

template <class T>
ListNode<T> * List<T>::GetHead()
{

}

template <class T>
ListNode<T> * List<T>::GetTail()
{
	return head;
}

template <class T>
void List<T>::SetTail(ListNode<T>* newtail)
{
	tail = newtail;
}

template <class T>
ListNode<T>* List<T>::GetNodeAt(int index)
{
	if(index > this->GetCount() - 1 || index < 0){
		cout << "A wrong position!\n";
	}
	ListNode<T>* handle = head->GetLink();
	while(index){
		handle = handle->GetLink();
		--index;
	}
	return handle;
}

/*template <class T>*/
/*ListNode<T>* List<T>::GetCur()*/
/*{*/

/*}*/

/*template <class T>*/
/*ListNode<T>* List<T>::TowardCur()*/
/*{*/

/*}*/
