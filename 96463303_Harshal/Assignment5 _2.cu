#include<iostream>
#include<stdlib.h>
#include<time.h>
#include<math.h>
#include <cmath>
#include <cuda.h>
#include<bits/stdc++.h>
using namespace std;
#define ll long long int

const int Block_Size = 1024;


__global__ void Blelloch_Exclusive_Scan(ll *d_in, ll* d_out)
{
    __shared__ ll sh_array[Block_Size];

    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int tid = threadIdx.x;
    int bid = blockIdx.x;

    
    sh_array[tid] = d_in[id];
    __syncthreads();


    //  REDUCTION
    for(int k=2; k <= Block_Size; k *= 2)
    {
        if((tid+1) % k == 0)
        {
            sh_array[tid] =max( sh_array[tid - (k/2)],sh_array[tid]);
        }
        __syncthreads();
    }

   
    if(tid == (Block_Size - 1))
    {
        d_out[bid] = sh_array[tid];
        sh_array[tid] = 0;
    }
    __syncthreads();

    // DOWNSWEEP 
    for(int k = Block_Size; k >= 2; k /= 2)
    {
        if((tid+1) % k == 0)
        {
            ll temp = sh_array[tid - (k/2)];
            sh_array[tid - (k/2)] = sh_array[tid];
            sh_array[tid] =max( temp,sh_array[tid]);
        }
        __syncthreads();
    }

   
    d_in[id] = sh_array[tid];

    __syncthreads();
}

__global__ void Add(ll* d_in, ll* d_out)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int bid = blockIdx.x;

    d_in[id] = max(d_out[bid],d_in[id]);

    __syncthreads();
}

int main()
{
    ll *h_in, *h_scan;

    int Size;
    cout << "Enter size of the array.\n";
    cin >> Size;

    int Reduced_Size = (int)ceil(1.0*Size/Block_Size);
    int Array_Bytes = Size * sizeof(ll);
    int Reduced_Array_Bytes = Reduced_Size * sizeof(ll);
    h_in = (ll*)malloc(Array_Bytes);
    h_scan = (ll*)malloc(Array_Bytes);

    
    srand(time(0));
    for(ll i=0; i<Size; i++)
    {
        h_in[i] = rand()%10;
    }

   

    ll *d_in, *d_out, *d_sum;

    cudaMalloc((void**)&d_in, Reduced_Size*Block_Size*sizeof(ll));  
    cudaMalloc((void**)&d_out, Reduced_Array_Bytes);
    cudaMalloc((void**)&d_sum, sizeof(ll));

    
    cudaMemcpy(d_in, h_in, Array_Bytes, cudaMemcpyHostToDevice);

    Blelloch_Exclusive_Scan <<< Reduced_Size, Block_Size >>> (d_in, d_out);
   
    
    if(Size > Block_Size)
    {
        Blelloch_Exclusive_Scan <<< 1, Block_Size >>> (d_out, d_sum);
        Add <<< Reduced_Size, Block_Size >>> (d_in, d_out);
    }

    cudaMemcpy(h_scan, d_in, Array_Bytes, cudaMemcpyDeviceToHost);

    cudaFree(d_in);
    cudaFree(d_out);

    ll *pref;
    pref = (ll*)malloc(Array_Bytes);
    pref[0] = 0;
    for(ll i=1; i<Size; i++)
        pref[i] = max(pref[i-1] , h_in[i-1]);

    
    ll flag = 0;
    for(ll i=0; i<Size; i++)
    {
        if(h_scan[i] != pref[i])
        {
            flag = 1;
            break;
        }
    }
    if(flag == 0)
        cout << "Complete!\n";
  
}
