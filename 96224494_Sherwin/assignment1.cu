[200~#include<iostream>
using namespace std;

__global__ void AddArray(int* d_a,int* d_b, int* d_c,int Array_Size)
{
	    int id = blockIdx.x * blockDim.x + threadIdx.x;
	        if(id < Array_Size)
			        d_c[id] = d_a[id] + d_b[id];
}
int main()
{
	        int Array_Size;
	        cout << "Enter the array size : ";
	        cin >> Array_Size;
                int h_a[Array_Size],h_b[Array_Size], h_c[Array_Size];
	       ; int Array_Bytes = Array_Size * sizeof(int);  
	        for(int i=0; i<Array_Size; i++)
	         {
	            h_a[i] = i;
                    h_b[i] = i;
			       }
	        int *d_a,*d_b, *d_c;
	        cudaMalloc((void**)&d_b, Array_Bytes);
	        cudaMalloc((void**)&d_a, Array_Bytes);
	        cudaMalloc((void**)&d_c, Array_Bytes);
	    // Copy the array from CPU (h_in) to the GPU (d_in)
	         cudaMemcpy(d_b, h_b, Array_Bytes, cudaMemcpyHostToDevice);
	         cudaMemcpy(d_a, h_a, Array_Bytes, cudaMemcpyHostToDevice);
	         AddArray<<<ceil(1.0*Array_Size/1024), 1024>>>(d_a,d_b,d_c,Array_Size);
	    // Copy the resulting array from GPU (d_out) to the CPU (h_out)
	         cudaMemcpy(h_c, d_c, Array_Bytes, cudaMemcpyDeviceToHost);
	         for(int i=0; i<Array_Size; i++)
                  cout << h_c[i] << " ";
	          cudaFree(d_a);
	          cudaFree(d_b);
		  cudaFree(d_c);
}
