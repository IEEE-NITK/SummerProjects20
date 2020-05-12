#include<iostream>
#include <stdlib.h>
using namespace std;

//Device code

//Host code
int cpuDot(int* h_A, int* h_B, int size);
int gpuDot(int* h_A, int* h_B, int size);
void populateRandom(int* h_in, int size, int seed);
void printArray(int* arr, int size);

int main(int argc, char const *argv[])
{
	int size = 1000000;
	// cout << "Enter N: "; cin >>  size;
	int naive, parallel;
	int h_A[size]; populateRandom(h_A, size, 0);
	int h_B[size]; populateRandom(h_B, size, 5);

	// cout << "h_A: ";
	// printArray(h_A, size);
	// cout << endl;
	// cout << "h_B: ";
	// printArray(h_B, size);
	naive = cpuDot(h_A, h_B, size);
	cout << "Naive dot: " << naive << endl;
	// parallel = gpuDot(h_A, h_B, size);
	return 0;
}

int cpuDot(int* h_A, int* h_B, int size){
	int naive = 0;
	for (int i = 0; i < size; ++i)
	{
		naive += h_A[i]*h_B[i];
	}
	return naive;
}

// int gpuDot(int* h_A, int* h_B, int size){
// 	int 
// }

void populateRandom(int* h_in, int size, int seed){
	srand(seed);
	for (int i = 0; i < size; ++i)
	{
		int random = rand() % 10;
		h_in[i] = random;
	}
}

void printArray(int* arr,int size){
	for (int i = 0; i < size; ++i)
	{
		cout << arr[i] << ", ";
	}
}

