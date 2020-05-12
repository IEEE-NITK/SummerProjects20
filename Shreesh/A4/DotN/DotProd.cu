#include<iostream>
#include <stdlib.h>
using namespace std;

//Device code
__global__ void dotProduct(int* A, int* B, int* C, int size){
	int abs_id = threadIdx.x + blockDim.x * blockIdx.x;
	//term wise product 
	C[abs_id] = A[abs_id] * B[abs_id];
}

__global__ void dotProdSum(int* d_C, int* d_out, int size){
	int t_id = threadIdx.x; int b_id = blockIdx.x;
	int abs_id = threadIdx.x + blockDim.x * blockIdx.x;
	__shared__ int sh_data[1024];
	if(abs_id < size){
		sh_data[t_id] = d_C[abs_id];
	}
	__syncthreads();
	for(unsigned int s = blockIdx.x/2; s > 0; s = s/2){
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
	int size = 10;
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

	int d_out[size];
	int* d_sum = NULL;
	int parallel = 0;

	int array_bytes = size * sizeof(int);
	int reduced_size = (int)ceil(size*1.0/1024);

	cudaMalloc((void**)&d_A, array_bytes); 
	cudaMalloc((void**)&d_B, array_bytes);
	cudaMalloc((void**)&d_C, array_bytes);
	cudaMalloc((void**)&d_out, reduced_size);
	cudaMalloc((void**)&d_sum, sizeof(int));

	cudaMemcpy(d_A, h_A, array_bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, array_bytes, cudaMemcpyHostToDevice);

	int b = ceil(size * 1.0/1024);
	int t = 1024;

	//kernel call
	dotProduct<<<b, t>>>(d_A, d_B, d_C, size); //prod then sum
	dotProdSum<<<b, t, 1024*sizeof(int)>>>(d_C, d_out, size);
	dotProdSum<<<1, t, 1024*sizeof(int)>>>(d_out, d_sum, size);

	cudaMemcpy(&parallel, &d_sum, array_bytes, cudaMemcpyDeviceToHost);
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

