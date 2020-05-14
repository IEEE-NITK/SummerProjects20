#include <iostream>
using namespace std;

__global__  void Sum(float* d_a,float* d_b, int r,int c)
{
    int x=blockIdx.x*blockDim.x + threadIdx.x;
    int y=blockIdx.y*blockDim.y + threadIdx.y;
    int index=c*y+x;
    if(x<c && y<r)
        d_a[index]=d_a[index]+d_b[index];
}

int main() 
{
    int r,c;
    cin>>r>>c;
    float h_a[r][c], h_b[r][c];
    int bytes=r*c*sizeof(float);
    float count=1.0;
    for(int i=0;i<r;i++)
    {
        for(int j=0;j<c;j++)
        {
	    h_a[i][j]=count;
	    h_b[i][j]=count;
	    count=count+1.0;
        }
    }
	
    float *d_a, *d_b;
    cudaMalloc((void**)&d_b, bytes);
    cudaMalloc((void**)&d_a, bytes);
    cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    Sum<<<dim3(c,r,1),1 >>>(d_a,d_b,r,c);
    cudaMemcpy(h_a, d_a, bytes, cudaMemcpyDeviceToHost);
    
    for(int i=0; i<r; i++)
    {
        for(int j=0;j<c;j++)
        {
           cout<<h_a[i][j]<<" ";
        }
        cout<<"\n";
    }
    cudaFree(d_a);
    cudaFree(d_b);
}
