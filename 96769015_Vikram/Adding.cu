#include<iostream>
using namespace std;

__global__ void Add(float *array1, float *array2, float *out)
{
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	out[id] = array1[id] + array2[id];
	
}

int main()
{
	unsigned int array_Size;
		
	cout << "Enter the size of Array: ";
	cin >> array_Size;

	float h_array1[array_Size], h_array2[array_Size], h_out[array_Size];
	
	int array_Bytes = array_Size * sizeof(float);

	for(int i=0;i<array_Size;i++)
		h_array1[i] = i;

	for(int i=1,j=0;j<array_Size;j++){
		h_array2[j] = i;
		
	}

	float *d_array1, *d_array2, *d_out;
	
	cudaMalloc((void**)&d_array1, array_Bytes);
	cudaMalloc((void**)&d_array2,array_Bytes);
	cudaMalloc((void**)&d_out,array_Bytes);
	
	cudaMemcpy(d_array1, h_array1, array_Bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_array2, h_array2, array_Bytes, cudaMemcpyHostToDevice);
	

	Add<<<ceil(1.0*array_Size/1024),1024>>>(d_array1, d_array2, d_out);

	cudaError e = cudaMemcpy(h_out, d_out, array_Bytes, cudaMemcpyDeviceToHost);
	
	if(e!=cudaSuccess)
        	cout <<"CUDA error copying to Host: " << cudaGetErrorString(e) << endl;
	
	for(int i=0;i<array_Size;i++)
		cout<< i << ". " << h_out[i] << "\n";
	
	cudaFree(d_array1);
	cudaFree(d_array2);
	cudaFree(d_out); 

}