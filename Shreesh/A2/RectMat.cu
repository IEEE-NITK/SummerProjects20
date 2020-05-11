#include <iostream>
#include <cstdlib>
#include <ctime>
#include<iomanip>
#include<chrono>
using namespace std;
using namespace std::chrono;

//Device code
__global__ void AddN(float* a, float* b, 
    float* c, int* ro, int* co){
    int x, y, idx;
    //assign a thread to each element (i,j)
    x = blockIdx.x * blockDim.x + threadIdx.x;
    y = blockIdx.y * blockDim.y + threadIdx.y;
    
    /*
    Addressing logic:
    Traverse y number of column lengths followed 
    by an offset of x
    */

    idx = y * (*co) + x;
    
    if(y < *ro && x < *co){
        *(c+idx) = *(a+idx) + *(b+idx);
        // c[idx] = a[idx] + b[idx];
    }
    }

//Host code
int row, col;

void printArr(float *arr, char x);
void fillRandom(float* arr, unsigned int seed);
void cpu_add(float* a, float* b, float* d);
void resultComp(float* a, float* b);

int main() 
{ 
    cout << "Enter row and col for the matrices: " << endl;
    cout << "Row: "; cin >> row;
    cout << "Column: "; cin >> col;

    char display = 'n';
    if(col <= 3)
    display = 'y';
    else
    display = 'n';

    if(col > 3){
        cout << "Do you want to display the results?(y/n): "; 
        cin >> display;
    }
	float h_a[row][col]; //array A
	float h_b[row][col]; //array B
	float h_c[row][col]; //gpu result
	float h_d[row][col]; //cpu result

    //fill arrays with random floats 
    fillRandom((float *)h_a, 1);
    fillRandom((float *)h_b, 0);

    //Using CPU
    // cout << "Adding using CPU:" << endl;
    auto start_cpu = high_resolution_clock::now();
    cpu_add((float *)h_a, (float *)h_b, (float *)h_d);
    //stop time stamp
    auto stop_cpu = high_resolution_clock::now();
    auto cpu_time = duration_cast<nanoseconds>(stop_cpu-start_cpu);

    if(display=='y'){
        cout << "\nCPU Result: ";
        printArr((float *)h_d, 'D');
    }

    //Using GPU 
    //Pointers for GPU memory
    float* d_a = NULL;
    float* d_b = NULL;
    float* d_c = NULL;
    int* co = NULL;
    int* ro = NULL;
    //Allocating GPU memory
    int array_bytes = col * row * sizeof(float);
    cudaMalloc((void**)&d_a, array_bytes);
    cudaMalloc((void**)&d_b, array_bytes);
    cudaMalloc((void**)&d_c, array_bytes);
    cudaMalloc((void**)&co, sizeof(int));
    cudaMalloc((void**)&ro, sizeof(int));

    //Copying CPU --> GPU memory
    cudaMemcpy(d_a, h_a, array_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, array_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(ro, &row, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(co, &col, sizeof(int), cudaMemcpyHostToDevice);

    int bx, by, tx, ty;
    tx = ty = 32;
    bx = (int)ceil(1.0*col/tx);
    by = (int)ceil(1.0*row/ty);
    dim3 dimGrid(bx, by);
    dim3 dimBlock(tx, ty);

    //Kernel call
    // cout << "\nAdding using GPU:" << endl;
    auto start_gpu = high_resolution_clock::now();
    AddN<<< dimGrid, dimBlock >>> (d_a, d_b, d_c, ro, co);
    //time end stamp 
    auto stop_gpu = high_resolution_clock::now();
    auto gpu_time = duration_cast<nanoseconds>(stop_gpu-start_gpu);


    //Copying GPU --> CPU memory
    cudaMemcpy(h_c, d_c, array_bytes, cudaMemcpyDeviceToHost);
    if(display=='y'){
        cout << "\nGPU result:";
        printArr((float *)h_c, 'C');
    }

    resultComp((float*)h_c, (float*)h_d);
    cout << "\nTime analysis:" << endl;
    cout << "CPU execution time: " << cpu_time.count() << " nanosec" << endl;
    cout << "GPU execution time: " << gpu_time.count() << " nanosec" << endl;

    //De-allocate GPU memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    cudaFree(ro);
    cudaFree(co);

    return 0; 
} 

void printArr(float *arr, char x)
{ 
    cout << "\n\nArray " << x << ": " << endl;
    for (int i = 0; i < row; i++)
    {
        for (int j = 0; j < col; j++)
        {
            float val = *((arr+i*col)+j);
            cout << fixed << setprecision(2) << val << "  ";
        }
        cout << endl;
    }
} 

void fillRandom(float *arr, unsigned int seed){
    srand((unsigned int)seed);
    for (int i = 0; i < row; i++)
    {
        for (int j = 0; j < col; j++)
        {
            //generate random number
            float num = rand();
            float max = RAND_MAX;
            float random = num / max;
            random = int(random * 1000.0); 
            random = random / 100.0;
            //update
            *((arr + i*col)+j) = random;
        }
    }
}

void cpu_add(float* a, float* b, float* d){
    for (int y = 0; y < row; y++)
    {
        for (int x = 0; x < col; x++)
        {
            *((d+y*col)+x) = *((a+y*col)+x) + *((b+y*col)+x);
        }
    }
    
}

void resultComp(float* a, float* b){
    cout << "\nResult Analysis: " << endl;
    bool same = true;
    for (int i = 0; i < row; i++)
    {
        for (int j = 0; j < col; j++)
        {
            float val1 = *(a+i*col+j);
            float val2 = *(b+i*col+j); 
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
        cout << "Result doesn't match :/" << endl;
    }
    cout << "\n[Note: CPU will perform better for smaller mat sizes]" << endl;
        
}

