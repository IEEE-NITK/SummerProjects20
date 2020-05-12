#include<iostream>
#include<stdio.h>
using namespace std;

__global__ void AddArray(int* d_a,int col,int row)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    int id=col*y+x;
    int temp;
    if(x < col &&y < row)
    temp = d_a[id];
    __syncthreads();
    int idr=row*x+y;
    d_a[idr]=temp;
   
   
}
int main()
{
    int row,col;
    printf("enter row and col");
    scanf("%d%d",&row,&col);
     
 
    int h_a[row][col],h_b[col][row];
    int Array_Bytes = row*col* sizeof(int);  
    for(int i=0; i<row; i++)
    {
       for(int j=0;j<col;j++)
       {
            h_a[i][j] = col*i+j;
            printf("%d\t", h_a[i][j]);
        }
      printf("\n");  
    }
    printf("\n");
    int *d_a;
   
    cudaMalloc((void**)&d_a, Array_Bytes);
 
    // Copy the array from CPU (h_in) to the GPU (d_in)
   
    cudaMemcpy(d_a, h_a, Array_Bytes, cudaMemcpyHostToDevice);
    AddArray<<<dim3(col,row,1),1 >>>(d_a,col,row);
    // Copy the resulting array from GPU (d_out) to the CPU (h_out)
    cudaMemcpy(h_b, d_a, Array_Bytes, cudaMemcpyDeviceToHost);
    for(int i=0; i<col; i++)
    {
       for(int j=0;j<row;j++)
       {
           printf("%d\t", h_b[i][j]);
        }
       printf("\n");
    }
    cudaFree(d_a);
}


