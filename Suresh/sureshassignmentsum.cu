//assignment of arrays sum

#include<iostream>
using namespace std;
__global__ void Sum(float* d1_in, float* d2_in, float* d_out, int* d_arraysize)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id < *d_arraysize)
        d_out[id] = d1_in[id] + d2_in[id];
}
int main()
{
    int h_arraysize;
    h_arraysize=100000;
    float h1_in[h_arraysize], h_out[h_arraysize] , h2_in[h_arraysize];
    int Array_Bytes = h_arraysize * sizeof(int);  
    for(int i=0; i<h_arraysize; i++)
    {
        h1_in[i]=i;
    }
    for(int i=0; i<h_arraysize;i++)
    {
	 h2_in[i]=i;
    }
    float *d1_in,*d2_in,*d_out;
    int *d_arraysize;
    cudaMalloc((void**)&d1_in, Array_Bytes);
    cudaMalloc((void**)&d2_in, Array_Bytes);
    cudaMalloc((void**)&d_out, Array_Bytes);
    cudaMalloc((void**)&d_arraysize,sizeof(int));
    // Copy the array from CPU (h_in) to the GPU (d_in)
    cudaMemcpy(d1_in, h1_in, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d2_in, h2_in, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_arraysize, &h_arraysize, sizeof(int), cudaMemcpyHostToDevice);
    Sum <<<ceil(1.0*h_arraysize/1024), 1024>>>(d1_in,d2_in,d_out,d_arraysize);
    // Copy the resulting array from GPU (d_out) to the CPU (h_out)
    cudaMemcpy(h_out, d_out, Array_Bytes, cudaMemcpyDeviceToHost);
    for(int i=h_arraysize-5; i<h_arraysize; i++)
        cout << h_out[i] << " ";
    cudaFree(d1_in);
    cudaFree(d2_in);
    cudaFree(d_out);
    cudaFree(d_arraysize);
}


