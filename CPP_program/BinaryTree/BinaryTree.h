#include "binaryTreeNode.h"
#include <queue>

template <class T>
class BinaryTree{
	BinaryTreeNode<T> * m_root;
public:
	BinaryTree(){m_root = NULL;};
	BinaryTree(T data){m_root = new BinaryTreeNode<T>(data);};
	virtual ~BinaryTree();

	bool IsEmpty() const{return m_root == NULL? true:false;};
	bool IsLeftChild(BinaryTreeNode<T> *p){return p == GetParent(p)->GetLeftChild() ? true:false;};
	bool IsRightChild(BinaryTreeNode<T> *p){return p == GetParent(p)->GetRightChild() ? true:false;};
	BinaryTreeNode<T> * GetRoot(){return m_root;};
	BinaryTreeNode<T>* GetParent(BinaryTreeNode<T> *p){return Parent(root, p);};
	BinaryTreeNode<T>* LeftChild(BinaryTreeNode<T> *root)const{return root == NULL ? NULL:root->GetLeftChild();};
	BinaryTreeNode<T>* RightChild(BinaryTreeNode<T> *root) const { return root == NULL ? NULL:root->GetRightChild();};
	BinaryTreeNode<T>* LeftSibling(BinaryTreeNode<T> *Leftchild);
	BinaryTreeNode<T>* RightSibling(BinaryTreeNode<T> *Rightchild);
	T Retrieve(BinaryTreeNode<T> *p) const {return p->data;};
	void Assign(BinaryTreeNode<T> *p, const T &d){p->SetData(d);};
	void InsertLeftChild(BinaryTreeNode<T> *p, const T& d) const;
	void InsertRightChild(BinaryTreeNode<T> *p, const T& d) const;
	void DeleteLeftChild(BinaryTreeNode<T> *p){Destroy(p->GetLeftChild());};
	void DeleteRightChild(BinaryTreeNode<T> *p){Destroy(p->GetRightChild());};
	virtual void PreOrderTraverse(BinaryTreeNode<T> *root) const;
	virtual void InOrderTraverse(BinaryTreeNode<T> *root) const;
	virtual void PostOrderTraverse(BinaryTreeNode<T> *root) const;
	virtual void LevelOrderTraverse(BinaryTreeNode<T> *root) const;
protected:
	BinaryTreeNode<T>* Parent(BinaryTreeNode<T>* root, BinaryTreeNode<T>* p);
	void Destroy(BinaryTreeNode<T>* p);
};


template <class T>
BinaryTree<T>::~BinaryTreeNode() {
	Destroy(m_root);
	m_root = NULL;
}
template <class T>
BinaryTreeNode<T>* BinaryTree<T>::LeftSibling(BinaryTreeNode<T> *LeftChild) {
	BinaryTreeNode<T>* p;
	p = Parent(m_root, LeftChild);
	if(p == NULL || LeftChild == p->GetLeftChild())
		return NULL;
	else
		return p->GetLeftChild();
}
template <class T>
BinaryTreeNode<T>* BinaryTree<T>::RightSibling(BinaryTreeNode<T> *Rightchild) {
	BinaryTreeNode<T>* p;
	p = Parent(m_root, RightChild);
	if(p == NULL || RightChild == p->GetRightChild())
		return NULL;
	else
		return p->GetRightChild();
}
template <class T>
void BinaryTree<T>::InsertLeftChild(BinaryTreeNode<T> *p, const T& d) const {
	BinaryTreeNode<T> * q = new BinaryTreeNode<T>(d);
	q->SetLeftChild(p->GetLeftChild());
	p->SetLeftChild(q);
}
template <class T>
void BinaryTree<T>::InsertRightChild(BinaryTreeNode<T> *p, const T& d) const {
	BinaryTreeNode<T> * q = new BinaryTreeNode<T>(d);
	q->SetRightChild(p->GetRightChild());
	p->SetRightChild(q);
}
template <class T>
void BinaryTree<T>::PreOrderTraverse(BinaryTreeNode<T> *root) const {
	if(root != NULL){
		cout << root->GetData();
		PreOrderTraverse(root->GetLeftChild());
		PreOrderTraverse(root->GetRightChild());
	}
}
template <class T>
void BinaryTree<T>::InOrderTraverse(BinaryTreeNode<T> *root) const {
	if(root != NULL){
		PreOrderTraverse(root->GetLeftChild());
		cout << root->GetData();
		PreOrderTraverse(root->GetRightChild());
	}
}
template <class T>
void BinaryTree<T>::PostOrderTraverse(BinaryTreeNode<T> *root) const {
	if(root != NULL){
		PreOrderTraverse(root->GetLeftChild());
		PreOrderTraverse(root->GetRightChild());
		cout << root->GetData() << endl;
	}
}
template <class T>
void BinaryTree<T>::LevelOrderTraverse(BinaryTreeNode<T> *root) const {
	queur<BinaryTreeNode<T> *> q;
	if(root != NULL)
		q.push(root);
	while(!q.empty()){
		root = q.front();q.pop();
		cout << root->GetData();
		if(root->GetLeftChild())
			q.push(root->GetLeftChild());
		if(root->GetRightChild())
			q.push(root->GetRightChild());
	}
}
template <class T>
BinaryTreeNode<T>* BinaryTree<T>::Parent(BinaryTreeNode<T>* root, BinaryTreeNode<T>* p) {
	BinaryTreeNode<T>* q;
	if(root == NULL)
		return NULL;
	if(root->GetLeftChild() == p || p == root->GetRightChild())
		return root;
	if((q = Parent(root->GetLeftChild(), p) != NULL)
			return q;
	else
		return Parent(root->GetRightChild(), p);
}
template <class T>
void BinaryTree<T>::Destroy(BinaryTreeNode<T>* p) {
	if(p != NULL){
		Destroy(p->GetLeftChild());
		Destroy(p->GetRightChild());
		Destroy(p);
	}
}
