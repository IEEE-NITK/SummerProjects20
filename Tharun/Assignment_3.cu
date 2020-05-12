#include<iostream>
using namespace std;
int Array_Size_x,Array_Size_y;

__global__ void Sum(float* d_in1,int* d_array_size_x,int* d_array_size_y)
{
    int j = threadIdx.x + blockIdx.x * blockDim.x;
    int k = threadIdx.y + blockIdx.y * blockDim.y;
	

        if (j < *d_array_size_y && k < *d_array_size_x)
        {
            int i1 = j + k * *d_array_size_y;
            int i2 = k + j * *d_array_size_x;
            
            float temp = d_in1[i1];
			__syncthreads();
            d_in1[i2]=temp;
        }
   
}
int main()
{
    cout << "Enter the array size (row , col) : ";
    cin >> Array_Size_x >> Array_Size_y;


    int Array_Bytes = Array_Size_x * sizeof(float) * Array_Size_y;

    float *h_in1,*h_out;

    h_in1 = (float*)malloc(Array_Bytes);
    h_out = (float*)malloc(Array_Bytes);

    for(int i=0; i<Array_Size_x; i++)
        for(int j = 0; j < Array_Size_y; j++)
            h_in1[i*Array_Size_y + j] = i + 0.1;

    for(int i=0; i<Array_Size_x; i++)
    {
        for(int j = 0; j < Array_Size_y; j++)
            cout << h_in1[i*Array_Size_y + j] << " ";
        cout << endl;
    }

    cout << endl;
    float *d_in1;
    int *d_array_size_x,*d_array_size_y;

    cudaMalloc((void**)&d_in1, Array_Bytes);
    cudaMalloc((void**)&d_array_size_x, sizeof(int));
    cudaMalloc((void**)&d_array_size_y, sizeof(int));

    cudaMemcpy(d_in1, h_in1, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_array_size_y, &Array_Size_y, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_array_size_x, &Array_Size_x, sizeof(int), cudaMemcpyHostToDevice);

    dim3 dimBlock(32, 32);
    dim3 dimGrid((int)ceil(1.0*Array_Size_y/dimBlock.x),(int)ceil(1.0*Array_Size_x/dimBlock.y));

    Sum<<<dimGrid, dimBlock>>>(d_in1,d_array_size_x,d_array_size_y);

    cudaMemcpy(h_out, d_in1, Array_Bytes, cudaMemcpyDeviceToHost);

    for(int i=0; i<Array_Size_y; i++)
    {
        for(int j = 0; j < Array_Size_x; j++)
            cout << h_out[i*Array_Size_x + j]<< " ";
        cout << endl;
    }

    cudaFree(d_in1);
    cudaFree(d_array_size_x);
    cudaFree(d_array_size_y);
}
