#include <iostream>
using namespace std;

__global__ void transpose(int *d_a, int *d_b, int r, int c)
{
    int x=blockIdx.x*blockDim.x + threadIdx.x;
    int y=blockIdx.y*blockDim.y + threadIdx.y;
    
    if(x<c && y<r)
    {
        int index_1=c*y+x;
        int index_2=r*x+y;
        int temp=d_a[index_1];
        __syncthreads();
        d_b[index_2]=temp;
    }
}

int main() 
{
    int r,c;
    cin>>r>>c;
    int bytes=r*c*sizeof(int);
    int h_a[r][c], h_b[c][r];
    for(int i=0;i<r;i++)
    {
        for(int j=0;j<c;j++)
        {
	        h_a[i][j]=i*(j+1);
        }
    }
    
    int *d_a, *d_b;
    cudaMalloc((void**)&d_a, bytes);
    cudaMalloc((void**)&d_b, bytes);
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    transpose<<<dim3(c,r,1),1 >>>(d_a,d_b,r,c);
    cudaMemcpy(h_b, d_b, bytes, cudaMemcpyDeviceToHost);
    
    for(int i=0; i<c; i++)
    {
        for(int j=0; j<r; j++)
        {
           cout<<h_b[i][j];
        }
        cout<<"\n";
    }
    cudaFree(d_a);
    cudaFree(d_b);
}