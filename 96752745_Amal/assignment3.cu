#include<iostream>
using namespace std;

__global__ void Transpose(int *d_a,int max){

int i = blockIdx.x*blockDim.x+threadIdx.x;
int j = blockIdx.y*blockDim.y+threadIdx.y;
int id1 = i+max*j;
int id2 = j+max*i;
__syncthreads();

if(i<max && j<max)
{
	int t = d_a[id1];
	__syncthreads();
	d_a[id1]=d_a[id2];
	__syncthreads();
	d_a[id2]=t;
}
	
}

int main()
{
	int r,c,i,j,max;
	cout<<"Enter the number of rows and columns:\n";
	cin>>r>>c;
	max=r>c?r:c;
	int h_a[max][max]={0};
	for(i=0;i<r;i++)
	{
		for(j=0;j<c;j++)
		h_a[i][j]=2*i+j;
	}
	int *d_a;
	cudaMalloc((void**)&d_a, max*max*sizeof(int));

	cudaMemcpy(d_a, h_a, max*max*sizeof(int), cudaMemcpyHostToDevice);
	dim3 dimBlock(32, 32);
    dim3 dimGrid((int)ceil(1.0*max/dimBlock.x), (int)ceil(1.0*max/dimBlock.y));
	Transpose<<<dimGrid,dimBlock>>>(d_a,max);
	cudaMemcpy(h_a, d_a, max*max*sizeof(int), cudaMemcpyDeviceToHost);
	cout<<"The transpose matrix is:\n";
	for(i=0;i<c;i++)
	{
		for(j=0;j<r;j++)
		cout<<h_a[i][j]<<" ";
		cout<<"\n";
	}

	cudaFree(d_a);
	return 0;
}