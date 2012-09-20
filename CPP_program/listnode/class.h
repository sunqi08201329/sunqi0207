template <class T> 
class ListNode{
	T data;
	ListNode<T> *link;
public:
	ListNode():link(NULL){}
	ListNode(T value):link(NULL),data(value){}
	~ListNode(){};
	void SetLink(ListNode<T> *next);
	ListNode<T> *GetLink();
	T& GetData();
};


template <class T> 
void ListNode<T>::SetLink(ListNode<T> *next)
{
	link = next;
}
template <class T>
ListNode<T> * ListNode<T>::GetLink(){
	return link;
}
template <class T>
T& ListNode<T>::GetData(){
	return data;
}
