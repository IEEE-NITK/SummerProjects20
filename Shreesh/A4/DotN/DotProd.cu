#include<iostream>
#include <stdlib.h>
using namespace std;

//Device code
__global__ void dotProduct(int* A, int* B, int* C, int size){
	int abs_id = threadIdx.x + blockDim.x * blockIdx.x;
	//term wise product in global memory 
	C[abs_id] = A[abs_id] * B[abs_id];
}

__global__ void dotProdSum(int* d_C, int* d_out, int size){
	
	int t_id = threadIdx.x; int b_id = blockIdx.x;
	int abs_id = threadIdx.x + blockDim.x * blockIdx.x;
	__shared__ int sh_data[1024];
	__syncthreads();
	
	//global -> shared memory 
	if(abs_id < size){
		sh_data[t_id] = d_C[abs_id];
	}
	__syncthreads();

	//reduce operation
	for(unsigned int s = blockDim.x/2; s > 0; s = s/2){
		__syncthreads();
		if(abs_id >= size || abs_id + s >= size){
			continue;
		}
		__syncthreads();

		if(t_id < s){
			sh_data[t_id] += sh_data[t_id + s];
		}
		__syncthreads();
	}

	if(t_id == 0){
		//each shared memory (per block) -> global array
		d_out[b_id] = sh_data[t_id];
	}

}
//Host code
int cpuDot(int* h_A, int* h_B, int size);
int gpuDot(int* h_A, int* h_B, int size);
void populateRandom(int* h_in, int size, int seed);
void printArray(int* arr, int size);

int main(int argc, char const *argv[])
{
	int size;
	cout << "Enter N: "; cin >>  size;
	int naive, parallel; bool ans = 0;
	int h_A[size]; populateRandom(h_A, size, 0); 
	int h_B[size]; populateRandom(h_B, size, 5);

	if(size > 10){
		cout << "Size of arrays too large." << endl;
		cout << "Do you still want me to display? (1/0):";
		cin >> ans;
	}
	if(ans==1){
		cout << "Array A: ";
		printArray(h_A, size);
		cout << endl;
		cout << "Array B: ";
		printArray(h_B, size);
	}
	naive = cpuDot(h_A, h_B, size);
	cout << "\n\nNaive dot: " << naive << endl;
	parallel = gpuDot(h_A, h_B, size);
	cout << "Parallel dot: " << parallel << endl;
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

int gpuDot(int* h_A, int* h_B, int size){
	int* d_A = NULL;
	int* d_B = NULL;
	int* d_C = NULL;
	int* d_out = NULL;
	int* d_sum = NULL;
	int parallel = 0;

	int array_bytes = size * sizeof(int);
	int reduced_size = (int)ceil(size*1.0/1024);
	int reduced_bytes = reduced_size * sizeof(int);

	cudaMalloc((void**)&d_A, array_bytes); 
	cudaMalloc((void**)&d_B, array_bytes);
	cudaMalloc((void**)&d_C, array_bytes);
	cudaMalloc((void**)&d_out, reduced_bytes);
	cudaMalloc((void**)&d_sum, sizeof(int));

	cudaMemcpy(d_A, h_A, array_bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, array_bytes, cudaMemcpyHostToDevice);

	int b = ceil(size * 1.0/1024);
	int t = 1024;

	// int h_C[size];
	// cudaMemcpy(h_C, d_C, array_bytes, cudaMemcpyDeviceToHost);
	// for (int i = 0; i < size; ++i)
	// {
	// 	cout << "h_C: " << h_C[i] << endl;
	// }

	//kernel call - product then sum
	dotProduct<<<b, t>>>(d_A, d_B, d_C, size); 

	dotProdSum<<<b, t>>>(d_C, d_out, size);
	dotProdSum<<<1, t>>>(d_out, d_sum, reduced_size);

	cudaMemcpy(&parallel, d_sum, sizeof(int), cudaMemcpyDeviceToHost);
	// parallel = 1;
	return parallel;
}

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

