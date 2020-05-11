#include <iostream>
#include <cstdlib>
#include <ctime>
using namespace std;

//Device code
__global__ void AddN(float* a, float* b, 
    float* c, int* s){
    int i, j, idx;

    i = blockIdx.x * blockDim.x + threadIdx.x;
    j = blockIdx.y * blockDim.y + threadIdx.y;
    
    idx = i + (*s) * j;
    
    if(j < *s && i < *s){
        c[idx] = a[idx] + b[idx];
    }
    }

//Host code
int size;

void printArr(float *arr, char x);
void fillRandom(float* arr, unsigned int seed);
void cpu_add(float* a, float* b, float* d);
void resultComp(float* a, float* b);

int main() 
{ 
    cout << "Enter size of the square matrices: ";
    cin >> size;
    char display = 'n';

    if(size <= 3)
    display = 'y';
    else
    display = 'n';

    if(size > 3){
        cout << "Do you want to display the results?(y/n): "; 
        cin >> display;
    }
	float h_a[size][size]; //array A
	float h_b[size][size]; //array B
	float h_c[size][size]; //gpu result
	float h_d[size][size]; //cpu result

    //fill arrays with random floats 
    fillRandom((float *)h_a, 1);
    fillRandom((float *)h_b, 0);

    //Using CPU
    // cout << "Adding using CPU:" << endl;
    cpu_add((float *)h_a, (float *)h_b, (float *)h_d);

    if(display=='y'){
        cout << "\nCPU Result: ";
        printArr((float *)h_d, 'D');
    }

    //Using GPU 
    //Pointers for GPU memory
    float* d_a = NULL;
    float* d_b = NULL;
    float* d_c = NULL;
    int* s = NULL;
    //Allocating GPU memory
    int array_bytes = size * size * sizeof(float);
    cudaMalloc((void**)&d_a, array_bytes);
    cudaMalloc((void**)&d_b, array_bytes);
    cudaMalloc((void**)&d_c, array_bytes);
    cudaMalloc((void**)&s, sizeof(int));

    //Copying CPU --> GPU memory
    cudaMemcpy(d_a, h_a, array_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, array_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(s, &size, sizeof(int), cudaMemcpyHostToDevice);

    /*
        Kernel call; Block: b, Threads: t (max possible)
        n = size;
    - Since the maximum number of threads per block is limited to 1024, 
        we make squares of length sqrt(1024) = 32 
            t = 32, b = upper_ceil(n/32)
            parameter: dim(b,b,1), dim3(t,t,1)
    */      

    int bx, by, tx, ty;
    tx = ty = 32;
    bx = by = (int)ceil(1.0*size/32);       

    dim3 dimGrid(bx, by);   
    dim3 dimBlock(tx, ty);  

    //Kernel call
    // cout << "\nAdding using GPU:" << endl;
    AddN<<< dimGrid, dimBlock >>> (d_a, d_b, d_c, s);

    //Copying GPU --> CPU memory
    cudaMemcpy(h_c, d_c, array_bytes, cudaMemcpyDeviceToHost);
    if(display=='y'){
        cout << "\nGPU result:";
        printArr((float *)h_c, 'C');
    }

    resultComp((float*)h_c, (float*)h_d);

    //De-allocate GPU memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    cudaFree(s);

    return 0; 
} 

void printArr(float *arr, char x)
{ 
    cout << "\n\nArray " << x << ": " << endl;
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            cout << *((arr+i*size)+j) << "  ";
        }
        cout << endl;
    }
} 

void fillRandom(float *arr, unsigned int seed){
    srand((unsigned int)seed);
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            //generate random number
            float num = rand();
            float max = RAND_MAX;
            float random = num / max;
            random = int(random * 1000.0); 
            random = random / 100.0;
            //update
            *((arr + i*size)+j) = random;
        }
    }
}

void cpu_add(float* a, float* b, float* d){
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            *((d+i*size)+j) = *((a+i*size)+j) + *((b+i*size)+j);
        }
    }
    
}

void resultComp(float* a, float* b){
    bool same = true;
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            float val1 = *(a+i*size+j);
            float val2 = *(b+i*size+j); 
            if( val1 != val2 ){
                same = false;
                break;
            }
        }
        
    }

    if(same){
        cout << "Success!" << endl;
    }
    else
    {
        cout << "Result doesn't match" << endl;
    }
    
        
}

