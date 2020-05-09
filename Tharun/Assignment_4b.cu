#include<iostream>
using namespace std;
__global__ void mul(float* d_a,float* d_b, float* d_c,int *size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id <*size)
        d_c[id] = d_a[id] * d_b[id];
}

__global__ void Array_Add(float* d_out, float* d_array, float Size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int tid = threadIdx.x;
    int bid = blockIdx.x;
    __shared__ float sh_array[1024];
    // Shared memory that is exclusive for a block. 
    // An array of size 1024 declared for common access to all the threads in a block
    // Each block has its own shared memory
    
    // Copy data from global to shared memory
    if(id < Size)
        sh_array[tid] = d_array[id];
    __syncthreads();
    
    // Perform parallel reduction in shared memory
    for(int s = 512; s>0; s = s/2)
    {
        __syncthreads();
        if(id>=Size || id+s>=Size)
            continue;
        if(tid<s)
            sh_array[tid] += sh_array[tid + s];
        // Each iteration reduces size of active array by half
    }
    __syncthreads();
    // Only thread 0 of each block writes back the result of that block into global memory
    if(tid==0)
        d_out[bid] = sh_array[tid];   
}
float Find_Sum_GPU(float h_array[], int Size)
{
    float* d_array, *d_out, *d_sum;
    cudaMalloc((void**)&d_array, Size*sizeof(float));
    cudaMalloc((void**)&d_out, ceil(Size*1.0/1024)*sizeof(float));
    cudaMalloc((void**)&d_sum, sizeof(float));
    cudaMemcpy(d_array, h_array, sizeof(float) * Size, cudaMemcpyHostToDevice);
    float h_sum;
    Array_Add <<<ceil(Size*1.0/1024), 1024>>> (d_out, d_array, Size);
    Array_Add <<<1, 1024>>> (d_sum, d_out, ceil(Size*1.0/1024));
    cudaMemcpy(&h_sum, d_sum, sizeof(float), cudaMemcpyDeviceToHost);
    cudaFree(d_array);
    cudaFree(d_out);
    cudaFree(d_sum);
    return h_sum;
}
float Find_Sum_CPU(float h_array[], int Size)
{
    float naive_sum = 0;
    for(int i=0; i<Size; i++)
        naive_sum = naive_sum + h_array[i]; 
    return naive_sum;
}
int main()
{
    int Size;
    cout << "\nEnter the size of the array : ";
    cin >> Size;
    
	
	int Array_Bytes = Size* sizeof(float);  
	float h_in1[Array_Bytes],h_in2[Array_Bytes],h_out[Array_Bytes];
    for(int i=0; i<Size; i++)
       {
		h_in1[i] = i + 1.5;
		h_in2[i] = i + 2.5;
		}
		
		float *d_in1,*d_in2, *d_out;
	int *d_array_size;
	
    cudaMalloc((void**)&d_in1, Array_Bytes);
	cudaMalloc((void**)&d_in2, Array_Bytes);
    cudaMalloc((void**)&d_out, Array_Bytes);
	cudaMalloc((void**)&d_array_size, sizeof(int));
	
	
    cudaMemcpy(d_in1, h_in1, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_in2, h_in2, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_array_size, &Array_Bytes, sizeof(int), cudaMemcpyHostToDevice);

	mul<<<ceil(1.0*Size/1024), 1024 >>>(d_in1,d_in2,d_out,d_array_size);
	
	cudaMemcpy(h_out, d_out, Array_Bytes, cudaMemcpyDeviceToHost);
	
    float h_sum = Find_Sum_GPU(h_out, Size);
    float naive_sum = Find_Sum_CPU(h_out, Size);
	
    cout << "\nThe sum is " << h_sum << endl;
    if(h_sum == naive_sum)
        cout << "Result computed correctly.";
    else
        cout << "Result wrong!";
}
