#include<iostream>
#include<stdio.h>
using namespace std;
__global__ void Array_max(int* d_out, int* d_array, int Size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int tid = threadIdx.x;
    int bid = blockIdx.x;
    __shared__ int sh_array[1024];
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
            {
               if(sh_array[tid] < sh_array[tid + s])
                sh_array[tid]= sh_array[tid + s];
            }
        // Each iteration reduces size of active array by half
    }
    __syncthreads();
    // Only thread 0 of each block writes back the result of that block into global memory
    if(tid==0)
        d_out[bid] = sh_array[tid];  
}
__global__ void Array_min(int* d_out, int* d_array, int Size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int tid = threadIdx.x;
    int bid = blockIdx.x;
    __shared__ int sh_array[1024];
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
            {
               if(sh_array[tid] > sh_array[tid + s])
                sh_array[tid]= sh_array[tid + s];
            }
        // Each iteration reduces size of active array by half
    }
    __syncthreads();
    // Only thread 0 of each block writes back the result of that block into global memory
    if(tid==0)
        d_out[bid] = sh_array[tid];  
}
int Find_max_GPU(int h_array[], int Size)
{
    int* d_array, *d_out, *d_sum;
    cudaMalloc((void**)&d_array, Size*sizeof(int));
    cudaMalloc((void**)&d_out, ceil(Size*1.0/1024)*sizeof(int));
    cudaMalloc((void**)&d_sum, sizeof(int));
    cudaMemcpy(d_array, h_array, sizeof(int) * Size, cudaMemcpyHostToDevice);
    int h_sum;
    Array_max <<<ceil(Size*1.0/1024), 1024>>> (d_out, d_array, Size);
    Array_max <<<1, 1024>>> (d_sum, d_out, ceil(Size*1.0/1024));
    cudaMemcpy(&h_sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_array);
    cudaFree(d_out);
    cudaFree(d_sum);
    return h_sum;
}

int Find_min_GPU(int h_array[], int Size)
{
    int* d_array, *d_out, *d_sum;
    cudaMalloc((void**)&d_array, Size*sizeof(int));
    cudaMalloc((void**)&d_out, ceil(Size*1.0/1024)*sizeof(int));
    cudaMalloc((void**)&d_sum, sizeof(int));
    cudaMemcpy(d_array, h_array, sizeof(int) * Size, cudaMemcpyHostToDevice);
    int h_sum;
    Array_min <<<ceil(Size*1.0/1024), 1024>>> (d_out, d_array, Size);
    Array_min <<<1, 1024>>> (d_sum, d_out, ceil(Size*1.0/1024));
    cudaMemcpy(&h_sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_array);
    cudaFree(d_out);
    cudaFree(d_sum);
    return h_sum;
}



int Find_min_CPU(int h_array[], int Size)
{
    int naive_min = h_array[0] ;
    for(int i=0; i<Size-1; i++)
         {
            if(h_array[i]>h_array[i+1])
            naive_min=h_array[i+1];
         }
    return naive_min;
}



int Find_max_CPU(int h_array[], int Size)
{
    int naive_max = h_array[0];
    for(int i=0; i<Size-1; i++)
         {
            if(h_array[i]<h_array[i+1])
            naive_max=h_array[i+1];
         }
    return naive_max;
}




int main()
{
    int Size;
    printf("Enter the array size\n");
    scanf("%d",&Size);
    int h_array[Size];
    for(int i=0; i<Size; i++)
        h_array[i] =i+1;
    int max = Find_max_GPU(h_array, Size);
    int min = Find_min_GPU(h_array, Size);
    int naive_min = Find_min_CPU(h_array, Size);
    int naive_max = Find_max_CPU(h_array, Size);
    printf("max no is %d\n",max);
    printf("min no is %d\n",min);
    if(max==naive_max&&min==naive_min)
        printf("Result computed correctly\n");
    else
        printf("Result wrong!");
   
   
}
