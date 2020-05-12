#include<iostream>
using namespace std;
int Array_Size;

__global__ void Sum(float* d_in1,float* d_in2, float* d_out,int* d_array_size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id < *d_array_size)
     d_out[id] = d_in1[id] + d_in2[id];    
}
int main()
{
    cout << "Enter the array size : ";
    cin >> Array_Size;
	
    float h_in1[Array_Size],h_in2[Array_Size],h_out[Array_Size];
    int Array_Bytes = Array_Size * sizeof(float);  
	
    for(int i=0; i<Array_Size; i++)
    {
        h_in1[i] = i + 0.1;
		h_in2[i] = i + 0.2;
    }
	
    float *d_in1,*d_in2, *d_out;
	int *d_array_size;
	
    cudaMalloc((void**)&d_in1, Array_Bytes);
	cudaMalloc((void**)&d_in2, Array_Bytes);
    cudaMalloc((void**)&d_out, Array_Bytes);
	cudaMalloc((void**)&d_array_size, sizeof(int));

    cudaMemcpy(d_in1, h_in1, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_in2, h_in2, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_array_size, &Array_Size, sizeof(int), cudaMemcpyHostToDevice);
	
    Sum<<<ceil(1.0*Array_Size/1024), 1024>>>(d_in1, d_in2, d_out,d_array_size);
	
    cudaMemcpy(h_out, d_out, sizeof(float), cudaMemcpyDeviceToHost);

    cudaFree(d_in1);
	cudaFree(d_in2);
    cudaFree(d_out);
	cudaFree(d_array_size);
}
