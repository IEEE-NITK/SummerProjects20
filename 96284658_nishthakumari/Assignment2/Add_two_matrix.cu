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
    int M,N;
    cout << "Enter the number of row : ";
    cin >> M;
    cout << "Enter the number of Column : ";
    cin >> N;
    
    float *h_a, *h_b, *h_c;

    int Array_Bytes = N*M* sizeof(float);  

    
 

    // Declaring pointers for allocation on the device 
    float* d_a;
    float* d_b;
    float* d_c;

    // Allocating device memory
    cudaMalloc((void**)&d_a,  Array_Bytes);
    cudaMalloc((void**)&d_b,  Array_Bytes);
    cudaMalloc((void**)&d_c,  Array_Bytes);
    
    
    
    
    h_a = (float *)malloc(Array_Bytes); 
    h_b = (float *)malloc(Array_Bytes);
    h_c = (float *)malloc(Array_Bytes);
    
    for (int i = 0; i <  M; i++) 
      for (int j = 0; j < N; j++) 
         *(h_a + i*N + j) = i%10;
         
         
    for ( int i = 0; i <  M; i++) 
      for ( int j = 0; j < N; j++) 
         *(h_b + i*N + j) = j%10;      

    // Copying input operands from host to device
    // For the GPU to perform any operation, the data has to be present in the GPU memory
    cudaMemcpy(d_a, h_a,  Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b,  Array_Bytes, cudaMemcpyHostToDevice);

    // Launching kernel with 1 block and 1 thread
    // The host launches the kernel on the device
   
    Add<<<ceil(1.0*N*M/1024), 1024>>>(d_a, d_b, d_c,N*M);

    // Copying the result from device to host
    cudaMemcpy(h_c, d_c, Array_Bytes, cudaMemcpyDeviceToHost);
     

   int flag=0;
    
        
    cout<<"\n";
    for (int i = 0; i <  M; i++) 
      for ( int j=0;j<N;j++) 
        if( ((*(h_a + i*N + j))+(*(h_b + i*N + j) ))!= *(h_c + i*N + j)) 
        flag=1;
        
        
    if(flag)
    cout<<"result error";
    else
    cout<<"correct result";
    
    
    //for (int i = 0; i <  M; i++) 
    //  for (int j = 0; j < N; j++) 
    //   cout<<  *(h_a + i*N + j) <<" ",cout<<endl;
       
         
    //for (int i = 0; i <  M; i++) 
    //  for (int j = 0; j < N; j++) 
    //    cout<< *(h_b + i*N + j)<<" ",cout<<endl; 
    //for (int i = 0; i <  M; i++) 
    //  for (int j = 0; j < N; j++) 
    //    cout<< *(h_c + i*N + j) <<" ",cout<<endl;        
    cudaFree(d_a);    
    cudaFree(d_b);       
    cudaFree(d_c);
}
