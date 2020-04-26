#include<iostream>
using namespace std;

// GPU Code
// __global__ indicates that it is a GPU kernel, that can be called from the CPU
__global__ void Add(float* d_a, float* d_b, float* d_c, int N)
{
         int id = blockIdx.x * blockDim.x + threadIdx.x;
         if(id < N)
           
            d_c[id] = d_a[id] + d_b[id];
    
}

// CPU Code
int main()
{   
    int N;
    cout << "Enter the array size : ";
    cin >> N;
    float h_a[N], h_b[N], h_c[N];

    int Array_Bytes = N * sizeof(float);  

    for(int i=0; i<N; i++)
    {
        h_a[i] = i;
    }
    for(int i=0;i<N;i++)
    {
    h_b[i]=i+1;
    }
 

    // Declaring pointers for allocation on the device 
    float* d_a;
    float* d_b;
    float* d_c;

    // Allocating device memory
    cudaMalloc((void**)&d_a,  Array_Bytes);
    cudaMalloc((void**)&d_b,  Array_Bytes);
    cudaMalloc((void**)&d_c,  Array_Bytes);

    // Copying input operands from host to device
    // For the GPU to perform any operation, the data has to be present in the GPU memory
    cudaMemcpy(d_a, h_a,  Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b,  Array_Bytes, cudaMemcpyHostToDevice);

    // Launching kernel with 1 block and 1 thread
    // The host launches the kernel on the device
   
    Add<<<ceil(1.0*N/1024), 1024>>>(d_a, d_b, d_c,N);

    // Copying the result from device to host
    cudaMemcpy(h_c, d_c, Array_Bytes, cudaMemcpyDeviceToHost);
     

   
    for(int i=0; i<N; i++)
        cout << h_c[i] << " ";

    cudaFree(d_a);    
    cudaFree(d_b);       
    cudaFree(d_c);
}


