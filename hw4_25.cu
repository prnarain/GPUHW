
#include<stdio.h>
#define BLOCK 1024
#define N 100000

__global__ void compress(int * d_in, int * d_start, int * d_end){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < N){ 
    if (d_in[idx] < d_in[idx+1])
      d_start[idx] = idx+2;       

    if (idx == 0 and d_in[idx] == 1)
      d_start[idx] = 1;
                          
    if (idx == N and d_in[idx] == 1)
      d_end[idx] = N;
  
    if (d_in[idx] > d_in[idx+1])
      d_end[idx] = idx+1; 
  } 
}

__global__ void compressleft(int * d_start, int * d_end ){
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < N){ 
    if (d_start[idx] == 0 && d_start[idx+1] != 0 )  {
      d_start[idx]=d_start[idx+1]; d_start[idx+1]=0;
    }

    if (d_end[idx] == 0 && d_end[idx+1] != 0 )  {
      d_end[idx]=d_end[idx+1]; d_end[idx+1]=0;
    }
  }
}

__global__ void compressreduce(int * d_start, int * d_end, int * d_out){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < N){ 
    if (idx ==0){
        d_out[idx] = d_start[idx];
        d_out[idx+1] = d_end[idx]-d_start[idx]+1;
    }
    else{
      if (d_start[idx]!=0 && d_end[idx]!=0){
        d_out[idx*2] = d_start[idx];
        d_out[idx*2+1] = d_end[idx]-d_start[idx]+1;
      }
    }
  }
}

__global__ void decompress(int * d_in, int * d_out){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < N) {
    d_out[idx] = 0 ;
    if (idx % 2 == 0){
        for (int i=d_in[idx]-1; i<d_in[idx] + d_in[idx+1] -1; i++){
            d_out[i] = 1;
        }
    }
  }
  __syncthreads();
}

int main(){
  /* initialise */
  int *d_in, *d_out, *d_start, *d_end;
  int *h_in, *h_out, *h_start, *h_end;

  h_in = (int *)malloc(sizeof(int)*N);
  h_out = (int *)malloc(sizeof(int)*N);
  h_start = (int *)malloc(sizeof(int)*N);
  h_end = (int *)malloc(sizeof(int)*N);

  for(int a = 0; a < N ; a++){
    h_in[a] = rand() % 2 ;}

  cudaMalloc((void**) &d_in, sizeof(int)*N);
  cudaMalloc((void**) &d_out, sizeof(int)*N);
  cudaMalloc((void**) &d_start, sizeof(int)*N);
  cudaMalloc((void**) &d_end, sizeof(int)*N);

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  float ms = 0;
  float total = 0 ;

  
  //printf("input:   \t");
  for (int i = 0 ; i<N; i++){
    //printf("%d ",h_in[i]);
  }

  int n_blocks = (N/1024) + 1 ; 
/////////////////////* compress1 kernel call *///////////////////////////
  cudaMemcpy(d_in ,h_in, N*sizeof(int), cudaMemcpyHostToDevice);
  
  cudaEventRecord(start);
  compress<<<n_blocks,1024>>>(d_in, d_start, d_end);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&ms, start, stop);
  total = total + ms; 

  cudaMemcpy(h_start ,d_start, N*sizeof(int), cudaMemcpyDeviceToHost);
  cudaMemcpy(h_end ,d_end, N*sizeof(int), cudaMemcpyDeviceToHost);


  /// intermediate print for understanding  
  /*
  printf("\ncompress1 start:");
  for (int i = 0 ; i<N; i++){
    if (h_start[i] !=0)
        printf(" %d",h_start[i]);
  }
  printf("\ncompress1 end: \t");
  for (int i = 0 ; i<N; i++){
    if (h_end[i] !=0)
        printf(" %d",h_end[i]);
  }
  */
 
 ///////////////* compress2 left kernel call */ /////////////////////////
  for (int i = 0;i<N;i++){
    cudaEventRecord(start);
    compressleft<<<n_blocks,1024>>>(d_start, d_end);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&ms, start, stop);
    total = total + ms; 

    cudaDeviceSynchronize();
  }
  cudaMemcpy(h_start ,d_start, N*sizeof(int), cudaMemcpyDeviceToHost);
  cudaMemcpy(h_end ,d_end, N*sizeof(int), cudaMemcpyDeviceToHost);

  /// intermediate print for understanding   
  /*
  printf("\ncompress2 start:");
  for (int i = 0 ; i<N; i++){
    if (h_start[i] !=0)
        printf(" %d",h_start[i]);
  }
  printf("\ncompress2 end: \t");
  for (int i = 0 ; i<N; i++){
    if (h_end[i] !=0)
        printf(" %d",h_end[i]);
  }
  */
/////////////////////* compress reduce kernel call *///////////////////////////
  
  cudaEventRecord(start);
  compressreduce<<<n_blocks,1024>>>(d_start, d_end, d_out);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&ms, start, stop);
  total = total + ms; 

  cudaMemcpy(h_out ,d_out, N*sizeof(int), cudaMemcpyDeviceToHost);

  //printf("\n\ncompress:\t");
  for (int i = 0 ; i<N; i++){
    //if (h_out[i] !=0)
      //printf(" %d",h_out[i]);
  }

///////////////////* decompress kernel call */////////////////////////
  cudaMemcpy(d_in ,h_out, N*sizeof(int), cudaMemcpyHostToDevice);
  
  cudaEventRecord(start);
  decompress<<<n_blocks,1024>>>(d_in, d_out);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&ms, start, stop);
  total = total + ms; 

  cudaMemcpy(h_out, d_out, N*sizeof(int), cudaMemcpyDeviceToHost);
  
  //printf("\n\ndecompress: \t");
  for (int i = 0 ; i<N; i++){
    //printf(" %d",h_out[i]);
  }

  printf("\n\nsize of N %d\n", N);
  printf("\ntotal GPU time taken %lf\n",total/1000) ;

return 0;
}

/*

nvcc hw4_25.cu -o hw4_25cu.out 
./hw4_25cu.out 

*/