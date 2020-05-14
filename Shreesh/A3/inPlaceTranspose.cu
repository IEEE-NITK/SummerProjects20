        #include<iostream>
        using namespace std;

        //Device code
        __global__ void Transpose(int* d_arr, int *r, int *c){

            int x = blockDim.x * blockIdx.x + threadIdx.x;
            int y = blockDim.y * blockIdx.y + threadIdx.y;  
            __syncthreads();

            if(x < *c && y < *r){
                int idx_o = x + (*c) * y;
                // int idx_n = x * (*r) + y;
                //alternatively
                int idx_n = idx_o * (*r) - ((*r)*(*c)-1)*(y);
                // printf("Sending %d to %d \n", idx_o, idx_n);
                __syncthreads();

                //Read  
                int temp = d_arr[idx_o];

                __syncthreads();

                //Write
                d_arr[idx_n] = temp;
            }
        }

        //Host code
        void showArray(int* arr, int row, int col);
        void fillArray(int* arr, int row, int col);

        int main(int argc, char const *argv[])
        {
            //CPU fields
            int row, col;
            cout << "Enter dimensions of matrix: " << endl;
            cout << "Row: "; cin >> row; 
            cout << "Col: "; cin >> col; cout << endl;
            int array_bytes = row * col * sizeof(int);
            int* h_arr = (int*)malloc(array_bytes);

            //GPU fields 
            int *d_arr = NULL;
            int *r = NULL;
            int *c = NULL;
            cudaMalloc((void**)&d_arr, array_bytes);
            cudaMalloc((void**)&r, sizeof(int));
            cudaMalloc((void**)&c, sizeof(int));

            //Fill  
            fillArray((int*)h_arr, row, col);

            //Print input
            cout << "Input Matrix: " << endl;
            showArray((int*)h_arr, row, col);

            //Tranpose
            //Copying CPU --> GPU memory
            cudaMemcpy(d_arr, h_arr, array_bytes, cudaMemcpyHostToDevice);
            cudaMemcpy(r, &row, sizeof(int), cudaMemcpyHostToDevice);
            cudaMemcpy(c, &col, sizeof(int), cudaMemcpyHostToDevice);

            dim3 dimBlock(32, 32);
            dim3 dimGrid((int)ceil(1.0*col/32), (int)ceil(1.0*row/32));

            Transpose<<<dimGrid, dimBlock>>>(d_arr, r, c);

            //Copying GPU --> CPU memory
            cudaMemcpy(h_arr, d_arr, array_bytes, cudaMemcpyDeviceToHost);
            cudaMemcpy(&row, c, sizeof(int), cudaMemcpyDeviceToHost);
            cudaMemcpy(&col, r, sizeof(int), cudaMemcpyDeviceToHost);

            //Print output
            cout << "Output Matrix" << endl;
            showArray((int*)h_arr, row, col);

            cudaFree(d_arr);
            cudaFree(c);
            cudaFree(r);

            return 0;
        }

        void showArray(int* arr, int row, int col){
            for (int i = 0; i < row; i++)
            {
                for (int j = 0; j < col; j++)
                {
                    cout << *((arr+i*col+j)) << " ";
                }
                cout << endl;
            }
        }

        void fillArray(int* arr, int row, int col){
            int count = 0;
            for (int i = 0; i < row; i++)
            {
                for (int j = 0; j < col; j++)
                {
                    *((arr+i*col+j)) = ++count;
                }
                
            }
        }