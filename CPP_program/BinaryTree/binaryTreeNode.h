#ifndef __BINARYTREENODE__H__
#define  __BINARYTREENODE__H__
#include "iostread"
using namespace std;

template <class T>
class BinaryTreeNode{
	T m_data;
	BinaryTreeNode<T> * m_leftChild;
	BinaryTreeNode<T> * m_rightChild;
public:
	BinaryTreeNode(){m_leftChild = m_rightChild = NULL;};
	BinaryTreeNode(const T &data, BinaryTreeNode *leftChild = NULL, BinaryTreeNode *rightChild = NULL){
		m_data = data;
		m_leftChild = leftChild;
		m_rightChild = rightChild;
	};
	T & GetData(){return m_data;};
	BinaryTreeNode<T> * GetLeftChild(){return m_leftChild;};
	BinaryTreeNode<T> * GetRightChild(){return m_rightChild;};

	void SetData(const T & data){m_data = data;};
	void SetLeftChild(BinaryTreeNode<T> *leftChild){m_leftChild = leftChild;};
	void SetRightChild(BinaryTreeNode<T> *RightChild){m_RightChild = RightChild;};
#endif
