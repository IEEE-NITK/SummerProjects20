#include<iostream>
using namespace std;
int arr_size_x,arr_size_y;

__global__ void Sum(float* d_in1,float* d_in2, float* d_out,int* d_arr_size_x,int* d_arr_size_y)
{
	int j = threadIdx.x + blockIdx.x * blockDim.x;
    int k = threadIdx.y + blockIdx.y * blockDim.y;

	int i = k + j * *d_arr_size_y;

    if (k < *d_arr_size_y && j < *d_arr_size_x) 
       d_out[i] = d_in1[i] + d_in2[i];
}
int main()
{
    cout << "Enter the array size (row , col) : ";
    cin >> arr_size_x >> arr_size_y;

    int arr_bytes = arr_size_x * sizeof(float) * arr_size_y;  

	float *h_in1, *h_in2, *h_out;

    h_in1 = (float*)malloc(arr_bytes);
    h_in2 = (float*)malloc(arr_bytes);
    h_out = (float*)malloc(arr_bytes);

    for(int i=0; i<arr_size_x; i++)
    {
		for(int j = 0; j < arr_size_y; j++)
			{ 
			h_in1[i*arr_size_y + j] = i + 0.1;
            h_in2[i*arr_size_y + j] = i + 0.2; 
			}
    }


    float *d_in1,*d_in2, *d_out;
	int *d_arr_size_x,*d_arr_size_y;

    cudaMalloc((void**)&d_in1, arr_bytes);
	cudaMalloc((void**)&d_in2, arr_bytes);
    cudaMalloc((void**)&d_out, arr_bytes);
	cudaMalloc((void**)&d_arr_size_x, sizeof(int));
	cudaMalloc((void**)&d_arr_size_y, sizeof(int));

    cudaMemcpy(d_in1, h_in1, arr_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_in2, h_in2, arr_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_arr_size_y, &arr_size_y, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_arr_size_x, &arr_size_x, sizeof(int), cudaMemcpyHostToDevice);

	 dim3 dimBlock(32, 32);
	 dim3 dimGrid((int)ceil(1.0*arr_size_x/dimBlock.x),(int)ceil(1.0*arr_size_y/dimBlock.y));

    Sum<<<dimGrid, dimBlock>>>(d_in1, d_in2, d_out,d_arr_size_x,d_arr_size_y);

    cudaMemcpy(h_out, d_out, arr_bytes, cudaMemcpyDeviceToHost);

	for(int i=0; i<arr_size_x; i++)
		{for(int j = 0; j < arr_size_y; j++)
			cout << h_out[i*arr_size_y + j]<< " ";
			cout << endl;
			}

    cudaFree(d_in1);
	cudaFree(d_in2);
    cudaFree(d_out);
	cudaFree(d_arr_size_x);
	cudaFree(d_arr_size_y);
}

