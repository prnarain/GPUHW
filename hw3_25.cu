
#include<stdio.h>
#include<stdlib.h>

#define N 1000

__global__ void encrypt(char *d_in, char *d_out){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int out; 
    if (i<N)
    {
        out = d_in[i] + (i+1) + 1 ; 
        if (out > 122) 
        out = (out - 123)%26 + 97 ; 
        d_out[i] = out;
    }
    __syncthreads();
}

__global__ void decrypt(char *d_in, char *d_out){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int out; 
    if (i<N)
    {
        out = d_in[i] - (i+1) - 1 ;
        if (out  < 97) 
            out = 122 - (96-out)%26   ; 
        d_out[i] = out;
    }
    __syncthreads();
}

int main(){
    
  /* initialise */
  char *d_in, *d_out;
  char *h_in, *h_out, *h_outf;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  float ms = 0;
  float total = 0 ; 

  h_in = (char *)malloc(sizeof(char)*N);
  h_out = (char *)malloc(sizeof(char)*N);
  h_outf = (char *)malloc(sizeof(char)*N);
  
  for(int a = 0; a < N ; a++){
    h_in[a] = "abcdefghijklmnopqrstuvwxyz"[random () % 26] ;}

  cudaMalloc((void**) &d_in, sizeof(char)*N);
  cudaMalloc((void**) &d_out, sizeof(char)*N);

  int n_blocks = N/1024 + 1 ; 
  
  cudaMemcpy(d_in, h_in, N*sizeof(char), cudaMemcpyHostToDevice);
  
  cudaEventRecord(start);
  encrypt<<<n_blocks,N>>>(d_in, d_out);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&ms, start, stop);
  total = total + ms; 

  cudaMemcpy(h_out, d_out, N*sizeof(char), cudaMemcpyDeviceToHost);
  
  cudaMemcpy(d_in, h_out, N*sizeof(char), cudaMemcpyHostToDevice);
  
  cudaEventRecord(start);
  decrypt<<<n_blocks,N>>>(d_in, d_out);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&ms, start, stop);
  total = total + ms; 

  cudaMemcpy(h_outf, d_out, N*sizeof(char), cudaMemcpyDeviceToHost);

  //printf("IP \t ENC \t DEC \t\t",N);
  //printf("\n");
  for(int a = 0; a < N ; a++){
    //printf("\n%d \t %d \t %d ",h_in[a], h_out[a], h_outf[a]) ;
    //printf("\n%c \t %c \t %c ",h_in[a], h_out[a], h_outf[a]) ;
  }
  
  printf("\n");
  printf("size of N %d\n", N);
  printf("\ntotal GPU time taken %lf\n",total) ;

  return 0;
}
