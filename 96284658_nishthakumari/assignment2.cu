#include<bits/stdc++.h>
using namespace std;






__global__ void MatrixAdd(float *a, float *b, float *c, int M,int N) {

   int col = threadIdx.x + blockIdx.x * blockDim.x;
   int row = threadIdx.y + blockIdx.y * blockDim.y;
   int index = col + row * N;
   if (col < N && row < M) {
       c[index] = a[index] + b[index];
   }
}



int main(){

  int *A, *B, *C;
  cout<<"Enter the number of row and column: ";
  cin>>M>>N;
  size_t dsize = M*N*sizeof(float);
  A = (float *)malloc(M*N*sizeof(float));
  B = (float *)malloc(M*N*sizeof(float));
  C = (float *)malloc(M*N*sizeof(float));

  for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++) {
      A[i][j] = 1.0;
      B[i][j] = 1.5;
      C[i][j] = 0.0;}

  float *d_A, *d_B, *d_C;
  cudaMalloc(&d_A, dsize);
  cudaMalloc(&d_B, dsize);
  cudaMalloc(&d_C, dsize);

  cudaMemcpy(d_A, A, dsize, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, dsize, cudaMemcpyHostToDevice);

  dim3 dimBlock(16,16);
  dim3 dimGrid((int)ceil(M/dimBlock.x),(int)ceil(N/dimBlock.y));

  MatrixAdd<<<dimGrid, dimBlock>>>(d_A, d_B, d_C,M, N);
  cudaMemcpy(C, d_C, dsize, cudaMemcpyDeviceToHost);
  for (int i = 0; i < M; i++)
    for (int j = 0; j < N; j++)
    {
      cout<<C[i][j] <<" ";
     }
  
  return 0;
}
