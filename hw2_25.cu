
#include <stdio.h>

__global__ void varcheck(int *x, int *y, int *z){
	int tid=threadIdx.x;
    
    if (tid %2 ==0)
        if (x==y)
            x=z;

    if (tid %2 ==1)
        if (x==z)
            x=y;
}

int main(){
  /* initialise */
  int *d_x, *d_y, *d_z ;
  int *h_x, *h_y, *h_z ;

  cudaMalloc((void**) &d_x, sizeof(int));
  cudaMalloc((void**) &d_y, sizeof(int));
  cudaMalloc((void**) &d_z, sizeof(int));

  //////

  //h_x = (int *)malloc(sizeof(char)*1);
  //h_y = (int *)malloc(sizeof(char)*1);
  //h_z = (int *)malloc(sizeof(char)*1);

  //h_x[1]= 15; h_y[1]= 15 ; h_z[1]= 26 ;

  //////

  cudaMemcpy(d_x, h_x, sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, h_y, sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_z, h_z, sizeof(int), cudaMemcpyHostToDevice);

  varcheck<<<1,2>>>(d_x,d_y,d_z);
  cudaMemcpy(h_x, d_x, sizeof(int), cudaMemcpyDeviceToHost);
  
  printf("\n%d",&h_x);
	return 0;
}
