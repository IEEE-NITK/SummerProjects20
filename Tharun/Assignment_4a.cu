#include<iostream>
using namespace std;
int Array_Size;

__global__ void Min(float* d_in1, float* d_out,int* d_array_size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
	int t_id = threadIdx.x;
    int b_id = blockIdx.x;
	
	__shared__ float a[1024];
	
    if(id < *d_array_size)
     a[t_id] = d_in1[id];    
	
	__syncthreads();
	
	for(int s = 512; s>0; s = s/2)
    {
        __syncthreads();
        if(id>=*d_array_size || id+s>=*d_array_size)
            continue;
        if(t_id<s)
            {
               if(a[t_id] > a[t_id + s])
                a[t_id]= a[t_id + s];
            }
        // Each iteration reduces size of active array by half
    }
    __syncthreads();
	
	 if(t_id==0)
        d_out[b_id] = a[t_id];   
}
__global__ void Max(float* d_in1, float* d_out,int* d_array_size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
	int t_id = threadIdx.x;
    int b_id = blockIdx.x;
	
	__shared__ float a[1024];
	
    if(id < *d_array_size)
     a[t_id] = d_in1[id];    
	
	__syncthreads();
	
	for(int s = 512; s>0; s = s/2)
    {
        __syncthreads();
        if(id>=*d_array_size || id+s>=*d_array_size)
            continue;
        if(t_id<s)
            {
               if(a[t_id] < a[t_id + s])
                a[t_id] = a[t_id + s];
            }
        // Each iteration reduces size of active array by half
    }
    __syncthreads();
	
	 if(t_id==0)
        d_out[b_id] = a[t_id];   
}
float Find_min_CPU(float h_array[], int Size)
{
    float naive_min = h_array[0] ;
    for(int i=0; i<Size-1; i++)
         {
            if(h_array[i]>h_array[i+1])
            naive_min=h_array[i+1];
         }
    return naive_min;
}



float Find_max_CPU(float h_array[], int Size)
{
    float naive_max = h_array[0];
    for(int i=0; i<Size-1; i++)
         {
            if(h_array[i]<h_array[i+1])
            naive_max=h_array[i+1];
         }
    return naive_max;
}
int main()
{
    cout << "Enter the array size : ";
    cin >> Array_Size;
	
    float h_in1[Array_Size],h_min,h_max;
    int Array_Bytes = Array_Size * sizeof(float);  
	int Array_Bytes_1 = (int)ceil(1.0*Array_Bytes/1024);  
	
    for(int i=0; i<Array_Size; i++)
    {
        h_in1[i] = i + 1.5;
    }
	
    float *d_in1, *d_out, *d_min,*d_max;
	int *d_array_size,*d_array_size_1;
	
    cudaMalloc((void**)&d_in1, Array_Bytes);
	cudaMalloc((void**)&d_min, sizeof(float));
	cudaMalloc((void**)&d_max, sizeof(float));
    cudaMalloc((void**)&d_out, Array_Bytes);
	cudaMalloc((void**)&d_array_size, sizeof(int));
	cudaMalloc((void**)&d_array_size_1, sizeof(int));

    cudaMemcpy(d_in1, h_in1, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_array_size, &Array_Size, sizeof(int), cudaMemcpyHostToDevice);
	 cudaMemcpy(d_array_size_1, &Array_Bytes_1, sizeof(int), cudaMemcpyHostToDevice);
    Min<<<((int)ceil(1.0*Array_Size/1024)), 1024>>>(d_in1, d_out, d_array_size);
	Min<<<1, 1024>>>(d_out, d_min, d_array_size_1);
	
	Max<<<((int)ceil(1.0*Array_Size/1024)), 1024>>>(d_in1, d_out,d_array_size);
	Max<<<1, 1024>>>(d_out, d_max,d_array_size_1);
	
	float naive_min = Find_min_CPU(h_in1, Array_Size);
    float naive_max = Find_max_CPU(h_in1, Array_Size);
	
    cudaMemcpy(&h_min, d_min, sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpy(&h_max, d_max, sizeof(float), cudaMemcpyDeviceToHost);
	
	cout << " Max " << h_max << " Min " << h_min << endl;
	//cout << " Max " << naive_max << " Min " << naive_min << endl;
	if(h_max==naive_max&&h_min==naive_min)
        printf("Result computed correctly\n");
    else
        printf("Result wrong!");

    cudaFree(d_in1);
	cudaFree(d_min);
	cudaFree(d_max);
    cudaFree(d_out);
	cudaFree(d_array_size);
}
