#include<iostream>
#include<string>
#include<cstdlib>
#include<ctime>
#include<math.h>
#include<chrono>
using namespace std;
using namespace std::chrono;

//Global variable 
unsigned long long int size;

//Display logged array
void showArr(float* arr, char x){
    cout << "\n\nArray " << x << " logged: " << endl;
    for(int i = 0; i < size; i++){
        cout << arr[i] << ", ";
    }
}

//Random number filler 
void fillRandom(float* arr){
    srand((unsigned int)time(NULL));
    for(int i = 0; i < size; i++){
        float random = (float(rand())/float((RAND_MAX)))*10;
        random = (float)(((int)(random * 100))/100.0);
        arr[i] = random;
    }
}

//Compare arrays
void compArrs(float* a, float*b){
    bool same = true;
    for(int i = 0; i < size; i++){
        if(a[i] != b[i]){
            same = false;
            break;
        }
    }

    if(same){
        cout << "Comparision successful!" << endl;
    }
    else{
        cout << "Comparision unsuccessful :/" << endl;
    }
}

//Function: CPU
void cpu_add(float* h_a, float* h_b, float* h_d){
    for (int i = 0; i < size; i++)
    {
        h_d[i] = h_a[i] + h_b[i];
    }
}

//Kernel: GPU
__global__ void Add(float* d_a, float* d_b, float* d_c){
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    d_c[id] = d_a[id] + d_b[id];
}


int main(){
    //Init GPU pointers
    float *d_a = NULL;
    float *d_b = NULL;
    float *d_c = NULL;

    cout << "Enter number of elements: "; cin >> size;
    //Init input arrays
    float h_a[size], h_b[size], h_c[size], h_d[size];
    
    //Log arrays
    string s = "random";
    cout << "\nRandom number generator or User input? (r/u): ";
    cin >> s; 
    
    //Choice of Random number generator or user input
    if(s=="u"){
        cout << "\nEnter " << size << " numbers for array A " << endl;
        for(int i = 0; i < size; i++){
            cin >> h_a[i];
        }
        cout << "\nEnter " << size << " numbers for array B " << endl;
        for(int i = 0; i < size; i++){
            cin >> h_b[i];
        }
    }
    else{
        fillRandom(h_a);
        fillRandom(h_b);
    }

    //Display arrays
    if(size > 10){
        cout << "\nArray size too large, do you still want me to display?(y/n): ";
        cin >> s; 
        if(s == "y"){
            showArr(h_a, 'A');
            showArr(h_b, 'B');
        }
    }
    else{
        showArr(h_a, 'A');
        showArr(h_b, 'B');
    }


    // Computing using CPU
    //start time stamp 
    auto start_cpu = high_resolution_clock::now();
    cpu_add(h_a, h_b, h_d);
    //stop time stamp
    auto stop_cpu = high_resolution_clock::now();
    auto cpu_time = duration_cast<nanoseconds>(stop_cpu-start_cpu);

    //CPU result
    if(s != "n"){ //dont display if the array size is too large
        cout << "\n\nCPU Result" << endl;
        for (int i = 0; i < size; i++)
        {
            cout << h_d[i] << ", ";
        }
    }

    //Computing using GPU    
    //Allocating memory in GPU pointed by d_x (x=a,b,c)
    int arr_bytes = size * sizeof(float);
    cudaMalloc((void**)&d_a, arr_bytes);
    cudaMalloc((void**)&d_b, arr_bytes);
    cudaMalloc((void**)&d_c, arr_bytes);

    // Copying CPU -->  GPU memory
    cudaMemcpy(d_a, h_a, arr_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, arr_bytes, cudaMemcpyHostToDevice);

    //Kernel call; Block: b, Threads: 1024 (max possible)
    //b = upper_ceil(1.0*size/1024)
    
    //time start stamp
    auto start_gpu = high_resolution_clock::now();
    Add<<< ceil(1.0*size/1024), 1024 >>>(d_a, d_b, d_c);
    //time end stamp 
    auto stop_gpu = high_resolution_clock::now();
    auto gpu_time = duration_cast<nanoseconds>(stop_gpu-start_gpu);

    //Copying GPU --> CPU memory
    cudaMemcpy(h_c, d_c, arr_bytes, cudaMemcpyDeviceToHost);

    //GPU Result 
    if(s != "n"){ //dont display if the array size is too large
        cout << "\n\nGPU Result" << endl;
        for(int i = 0;i < size; i++){
            cout << h_c[i] << ", ";
        }
    }

    //De-allocating memory
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c); 

    //Success if all elements match
    cout << "\nResult analysis: " << endl;
    compArrs(h_c, h_d);

    //Execution time analysis; 
    //GPU yields faster results for typically large array sizes 
    cout << "\nTime analysis:" << endl;
    cout << "CPU execution time: " << cpu_time.count() << " nanosec" << endl;
    cout << "GPU execution time: " << gpu_time.count() << " nanosec" << endl;
}