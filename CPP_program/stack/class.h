template <class T>
class ArrayStack{
	int size;
	int tos;
	T* contain;
public:
	ArrayStack():size(0),tos(0),contain(NULL){}
	ArrayStack(int MaxSize);
	void push(T& element);
	T& GetTop();
	T& Pop();
	bool IsEmpty();
	void MakeEmpty();
};

template <class T>
ArrayStack<T>::ArrayStack(int MaxSize) {
	size = MaxSize;
	tos = -1;
	contain = new T[size];
}

template <class T>
void ArrayStack<T>::push(T& element) {
	assert(tos != size - 1);
	contain[++tos] = element;
}

template <class T>
T& ArrayStack<T>::GetTop() {
	assert(tos != -1);
	return contain[tos];
}

template <class T>
T& ArrayStack<T>::Pop() {
	assert(tos != -1);
	return contain[tos--];
}

template <class T>
bool ArrayStack<T>::IsEmpty() {
	return tos == -1;
}

template <class T>
void ArrayStack<T>::MakeEmpty() {
	tos = -1;
}
