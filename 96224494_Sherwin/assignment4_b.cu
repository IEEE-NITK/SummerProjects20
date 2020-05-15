#include<stdio.h>

__global__ void mulArray(int* d_a,int* d_b, int* d_c,int size)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i <size)
        d_c[i] = d_a[i] * d_b[i];
}



__global__ void Array_Add(int* d_out, int* d_array, int Size)
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
            sh_array[tid] += sh_array[tid + s];
        // Each iteration reduces size of active array by half
    }
    __syncthreads();
    // Only thread 0 of each block writes back the result of that block into global memory
    if(tid==0)
        d_out[bid] = sh_array[tid];  
}
int Find_Sum_GPU(int h_array[], int Size)
{
    int* d_array, *d_out, *d_sum;
    cudaMalloc((void**)&d_array, Size*sizeof(int));
    cudaMalloc((void**)&d_out, ceil(Size*1.0/1024)*sizeof(int));
    cudaMalloc((void**)&d_sum, sizeof(int));
    cudaMemcpy(d_array, h_array, sizeof(int) * Size, cudaMemcpyHostToDevice);
    int h_sum;
    Array_Add <<<ceil(Size*1.0/1024), 1024>>> (d_out, d_array, Size);
    Array_Add <<<1, 1024>>> (d_sum, d_out, ceil(Size*1.0/1024));
    cudaMemcpy(&h_sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_array);
    cudaFree(d_out);
    cudaFree(d_sum);
    return h_sum;
}






int main()
{
    int size;
    printf("enter array size");
    scanf("%d",&size);
     
 
    int h_a[size],h_b[size],h_c[size];
    int Array_Bytes = size* sizeof(int);  
    for(int i=0; i<size; i++)
    {
       
            h_a[i]= 2;
            h_b[i]= 1;
    }
     
     
    printf("hello\n");
    int *d_a,*d_b, *d_c;
    cudaMalloc((void**)&d_b, Array_Bytes);
    cudaMalloc((void**)&d_a, Array_Bytes);
    cudaMalloc((void**)&d_c, Array_Bytes);
    // Copy the array from CPU (h_in) to the GPU (d_in)
    cudaMemcpy(d_b, h_b, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_a, h_a, Array_Bytes, cudaMemcpyHostToDevice);
    mulArray<<<size,1 >>>(d_a,d_b,d_c,size);
    // Copy the resulting array from GPU (d_out) to the CPU (h_out)
    cudaMemcpy(h_c, d_c, Array_Bytes, cudaMemcpyDeviceToHost);
    int h_sum = Find_Sum_GPU(h_c, size);
    printf("dot product sum is %d",h_sum);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
}
