template <class T> 
class DouListNode{
	T data;
	DouListNode<T> * link;
	DouListNode<T> * prior;
public:
	DouListNode():link(NULL);
	DouListNode(T value):link(NULL),prior(NULL),data(value){}
	~DouListNode(){};
	void SetLink(DouListNode<T> *next);
	void SetPrior(DouListNode<T> *pre);
	DouListNode<T>* GetLink();
	DouListNode<T>* GetPrior();
	T& GetData();
};

template <class T>
DouListNode<T>::SetLink(DouListNode<T> *next) {
	link = next;
}

template <class T>
DouListNode<T>::SetPrior(DouListNode<T> *pre) {
	link = pre;
}

template <class T>
DouListNode<T> *DouListNode<T>::GetLink() {
	return link;
}

template <class T>
DouListNode<T> *DouListNode<T>::GetPrior() {
	return prior;
}

T& DouListNode<T>::GetData() {
	return data;
}
