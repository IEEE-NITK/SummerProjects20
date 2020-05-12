#include<iostream>
using namespace std;

__global__ void Sum(float* d1_in, float* d2_in, float* d_out, int* d_arr_size)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < *d_arr_size)
    
    d_out[i] = d1_in[i] + d2_in[i];

}

int main()
{
	int arr_size;
    cout << "Enter array size : ";
    cin >> arr_size;
    float h1_in[arr_size], h_out[arr_size],h2_in[arr_size];
    int arr_bytes = arr_size * sizeof(float);  
    cout<<"Enter "<<arr_size<<" elements array 1 and array 2\n";
    for(int i=0; i<arr_size; i++)
    cin>>h1_in[i];
   
    for(int i=0; i<arr_size; i++)
    cin>>h2_in[i];

    float *d1_in, *d_out, *d2_in;
     int *d_arr_size;

    cudaMalloc((void**)&d1_in, arr_bytes);
    cudaMalloc((void**)&d2_in, arr_bytes);
    cudaMalloc((void**)&d_out, arr_bytes);
    cudaMalloc((void**)&d_arr_size,sizeof(float));

    cudaMemcpy(d1_in, h1_in, arr_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d2_in, h2_in, arr_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_arr_size, &arr_size, sizeof(float), cudaMemcpyHostToDevice);

    Sum<<<ceil(1.0*arr_size/1024), 1024>>>(d1_in, d2_in, d_out,d_arr_size);

    cudaMemcpy(h_out, d_out, arr_bytes, cudaMemcpyDeviceToHost);
    cout<<"Sum of the 2 arrays is\n";
    for(int i=0; i<arr_size; i++)
        cout << h_out[i] << " ";
    cudaFree(d1_in);
    cudaFree(d2_in);
    cudaFree(d_out);
    cudaFree(d_arr_size);

    }
