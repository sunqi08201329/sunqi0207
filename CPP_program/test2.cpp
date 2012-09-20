#include "iostream"
#include <string.h> 
#include <malloc.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <memory.h> 
using namespace std;

typedef struct  AA 
{ 
	int b1:5; 
	int b2:2; 
}AA; 

int main() 
{ 
	AA aa; 
	char cc[100]; 
	strcpy(cc,"0123456789abcdefghijklmnopqrstuvwxyz"); 
	memcpy(&aa,cc,sizeof(AA)); 
	cout << aa.b1 <<endl; 
	cout << aa.b2 <<endl; 
	return 0;
} 

