#include<iostream>
#include<stdio.h>
using namespace std;

__global__  void AddArray(int* d_a,int* d_b, int* d_c,int col,int row)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    int id=col*y+i;
    if(i < col &&y < row)
        d_c[id] = d_a[id] + d_b[id];
}
int main()
{
    int row,col;
    printf("enter row and col");
    scanf("%d%d",&row,&col);
     
 
    int h_a[row][col],h_b[row][col],h_c[row][col];
    int Array_Bytes = row*col* sizeof(int);  
    for(int i=0; i<row; i++)
    {
       for(int j=0;j<col;j++)
       {
            h_a[i][j] = i+j;
            h_b[i][j] = i+j;
        }
    }
    int *d_a,*d_b, *d_c;
    cudaMalloc((void**)&d_b, Array_Bytes);
    cudaMalloc((void**)&d_a, Array_Bytes);
    cudaMalloc((void**)&d_c, Array_Bytes);
    // Copy the array from CPU (h_in) to the GPU (d_in)
    cudaMemcpy(d_b, h_b, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_a, h_a, Array_Bytes, cudaMemcpyHostToDevice);
    AddArray<<<dim3(col,row,1),1 >>>(d_a,d_b,d_c,col,row);
    // Copy the resulting array from GPU (d_out) to the CPU (h_out)
    cudaMemcpy(h_c, d_c, Array_Bytes, cudaMemcpyDeviceToHost);
    for(int i=0; i<row; i++)
    {
       for(int j=0;j<col;j++)
       {
           printf("%d\t", h_c[i][j]);
        }
       printf("\n");
    }
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
}


