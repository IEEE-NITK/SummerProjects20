#include<iostream>
using namespace std;

__global__ void Add(float *d_a,float *d_b,float *d_c,int r,int c){
    
    int i =blockIdx.x*blockDim.x+threadIdx.x;
    int j =blockIdx.y*blockDim.y+threadIdx.y;
    int k = i+j*c;
    //i is defined for horizontal traversal
    if(i<c && j<r){
        d_c[k]=d_a[k]+d_b[k];
    }    
}


int main()
{
    int r,c,i,j;
    cout<<"Enter the rows and columns\n";
    cin>>r>>c;
    float h_a[r][c],h_b[r][c],h_c[r][c];
    for(i=0;i<r;i++)
    {
        for(j=0;j<c;j++)
        {
            h_a[i][j]=i+j+3;
            h_b[i][j]=i*j;
        }
    }
    float *d_a,*d_b,*d_c;
    cudaMalloc((void**)&d_a, (r*c)*sizeof(float));
    cudaMalloc((void**)&d_b, (r*c)*sizeof(float));
    cudaMalloc((void**)&d_c, (r*c)*sizeof(float));

    cudaMemcpy(d_a, h_a, r*c*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, r*c*sizeof(float), cudaMemcpyHostToDevice);

    dim3 dimBlock(32, 32);
    dim3 dimGrid((int)ceil(1.0*c/dimBlock.x),(int)ceil(1.0*r/dimBlock.y));
    Add<<<dimGrid,dimBlock>>>(d_a,d_b,d_c,r,c);
    cudaMemcpy(h_c, d_c, (r*c)*sizeof(float), cudaMemcpyDeviceToHost);

    cout<<"Sum of the 2 matrices is:\n";
    for(i=0;i<r;i++)
    {
        for(j=0;j<c;j++)
        {
            printf("%.2f ",h_c[i][j]);
        }
        cout<<"\n";
    }

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}