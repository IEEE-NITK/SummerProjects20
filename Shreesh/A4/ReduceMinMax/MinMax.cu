#include <iostream>
#include <ctime>
#include <stdlib.h>
using namespace std;

int size = 1024*1024; //2^20 elements

//Device code
__global__ void findMin(int* d_out, int* d_in, int size){
	int abs_id = threadIdx.x + blockDim.x * blockIdx.x;
	int t_id = threadIdx.x; 
	int b_id = blockIdx.x;

	__shared__ int sdata[1024];
	__syncthreads();

	//Copying data; global --> shared 
	if(abs_id < size){
		sdata[t_id] = d_in[abs_id];
		//there is one sdata array for every block
	}
	__syncthreads();

	//parallel reduce in shared memory
	for(unsigned int s = 1024/2; s > 0; s = s/2){
		//make sure all local s are initialized 
		__syncthreads();
		if(abs_id >= size || abs_id+s >= size)
			continue; 
		//make sure all unmapped threads are skipped 
		__syncthreads();

		if(t_id < s){
			if(sdata[t_id] > sdata[t_id + s]){
				//if +s is smaller then replace 
				sdata[t_id] = sdata[t_id + s];
			}
		}

		__syncthreads(); //All half comparisions are completed 
	} //each iteration reduces size of active array by half

	//Make sure all sdata[] have been reduced to size 1
	__syncthreads();

	if(t_id==0){
		d_out[b_id] = sdata[t_id];
	}
}

__global__ void findMax(int* d_out, int* d_in, int size){
	int abs_id = threadIdx.x + blockDim.x * blockIdx.x;
	int t_id = threadIdx.x; 
	int b_id = blockIdx.x;

	__shared__ int sdata[1024];
	__syncthreads();

	//Copying data; global --> shared 
	if(abs_id < size){
		sdata[t_id] = d_in[abs_id];
		//there is one sdata array for every block
	}
	__syncthreads();

	//parallel reduce in shared memory
	for(unsigned int s = 1024/2; s > 0; s = s/2){
		//make sure all local s are initialized 
		__syncthreads();
		if(abs_id >= size || abs_id+s >= size)
			continue; 
		//make sure all unmapped threads are skipped 
		__syncthreads();

		if(t_id < s){
			if(sdata[t_id] < sdata[t_id + s]){
				//if +s is greater then replace 
				sdata[t_id] = sdata[t_id + s];
			}
		}

		__syncthreads(); //All half comparisions are completed 
	} //each iteration reduces size of active array by half

	//Make sure all sdata[] have been reduced to size 1
	__syncthreads();

	if(t_id==0){
		d_out[b_id] = sdata[t_id];
	}
}

//Host code
void populateRandom(int* arr);
void printArray(int* arr);
void cpuMinMax(int* arr);
void gpuMinMax(int* h_in);
void compareResult(int* gpu, int* cpu);

//Driver function
int main(int argc, char const *argv[])
{
	int s = size;
	int h_in[s]; 
	populateRandom(h_in);
	cpuMinMax(h_in);
	gpuMinMax(h_in);
	return 0;
}

void gpuMinMax(int* h_in){

	int array_bytes = size * sizeof(int);
	int reduced_size = (int)ceil(size*1.0/1024);
	int reduced_bytes = reduced_size * sizeof(int);
	int* d_in  = NULL; //input array
	int* d_out = NULL; //reduced array
	int* d_min = NULL; //min
	int* d_max = NULL; //max
	int min, max;

	cudaMalloc((void**)&d_in, array_bytes);
	cudaMalloc((void**)&d_out,reduced_bytes);
	cudaMalloc((void**)&d_min, sizeof(int));
	cudaMalloc((void**)&d_max, sizeof(int));

	cudaMemcpy(d_in, h_in, array_bytes, cudaMemcpyHostToDevice);
	int b = ceil(size*1.0/1024);
	//find min
	findMin<<<b, 1024, 1024*sizeof(int)>>>(d_out, d_in, size);
	findMin<<<1, 1024, 1024*sizeof(int)>>>(d_min, d_out, ceil(size*1.0/1024));
	cudaMemcpy(&min, d_min, sizeof(int), cudaMemcpyDeviceToHost);
	//find max
	findMax<<<b, 1024, 1024*sizeof(int)>>>(d_out, d_in, size);
	findMax<<<1, 1024, 1024*sizeof(int)>>>(d_max, d_out, ceil(size*1.0/1024));
	cudaMemcpy(&max, d_max, sizeof(int), cudaMemcpyDeviceToHost);
	//result
	cout << "\nReducing using GPU" << endl;
	cout << "Min: " << min << " | Max: " << max << endl;

	//free gpu memory 
	cudaFree(d_in);
	cudaFree(d_out);
	cudaFree(d_max);
	cudaFree(d_min);

}

void populateRandom(int* h_in){
	unsigned int t = time(NULL);
	srand(t);
	for (int i = 0; i < size; ++i)
	{
		int random = rand();
		h_in[i] = random;
	}
}

void printArray(int* arr){
	for (int i = 0; i < size; ++i)
	{
		cout << arr[i] << ", ";
	}
}

void cpuMinMax(int* arr){
	int min, max;
	min = arr[0];
	max = arr[0];
	for (int i = 0; i < size; ++i)
	{
		if(min > arr[i])
			min = arr[i];
		if(max < arr[i])
			max = arr[i];
	}

	cout << "\nReducing using CPU" << endl;	
	cout << "Min: " << min << " | Max: " << max << endl;

}

