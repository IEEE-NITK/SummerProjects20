#include<iostream>
using namespace std;


__global__ void sum(float* d_a1, float* d_a2, int size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id<size)
    d_a1[id]=d_a1[id]+d_a2[id];
}

int main()
{
    int array_size;
    cout<<"enter array size : ";
    cin>>array_size;
    float h_a1[array_size], h_a2[array_size];
    int array_bytes=array_size*sizeof(float);
    //cout<<"elements of first array : ";
    for(int i=0; i<array_size; i++)
    {
        h_a1[i]=i;
    }
    //cout<<"elements of second array : ";
    for(int i=0; i<array_size; i++)
    {
        h_a2[i]=i;
    }
    
    float *d_a1, *d_a2;
    cudaMalloc((void**)&d_a1, array_bytes);
    cudaMalloc((void**)&d_a2, array_bytes);
    
    cudaMemcpy(d_a1, h_a1, array_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_a2, h_a2, array_bytes, cudaMemcpyHostToDevice);
    
    sum<<<ceil(1.0*array_size/1024), 1024>>>(d_a1, d_a2, array_size);
    cudaMemcpy(h_a1, d_a1, array_bytes, cudaMemcpyDeviceToHost);
    
    for(int i=0; i<array_size; i++)
        cout << h_a1[i] << " ";
    cudaFree(d_a1);
    cudaFree(d_a2);
}