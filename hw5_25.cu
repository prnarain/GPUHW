
#include<stdio.h>

#define N 1024
#define BLOCK 1024

__global__ void reduceV1(int *elems){
	int id,i;

	id=threadIdx.x+blockIdx.x*blockDim.x;
	for(i=N/2; i; i/=2) {
		if(id<i)
			elems[id] += elems[id+i];
		__syncthreads();
	}
	if(id==0)
		printf("GPU Sum approach 1 is %d %d\n",id , elems[0]);
}

__global__ void reduceV2(int *elems){
	int id, i;

	id=threadIdx.x+blockIdx.x*blockDim.x;
	for(i=N/2; i; i/=2) {
		if(id<i){
			if (id%2 ==0){
				elems[id] += elems[id+i];
			}
			if (id%2 ==1){
				elems[id] += elems[id+i];
			}
		}
		__syncthreads();
	}
	if(id==0)
		printf("GPU Sum approach 2 is %d %d\n",id , elems[0]);
}

__global__ void reduceV3(int *elems){
	int id, i;

	id=threadIdx.x+blockIdx.x*blockDim.x;
	for(i=N/2; i; i/=2) {
		if(id<i){
			if (id<i/2){
				elems[id] += elems[id+i];
			}
			if (id>=i/2 ){
				elems[id] += elems[id+i];
			}
		}
		__syncthreads();
	}
	if(id==0)
		printf("GPU Sum approach 3 is %d %d\n",id , elems[0]);
}


int main(){
	int host[N],i;
	int sum=0;

	for(i=0;i<N;i++){
		host[i]=rand()%20;
		sum+=host[i];
	}	

	printf("CPU Sum is %d\n",sum);

	int *d_elems, *d_out;

	cudaMalloc(&d_elems,N*sizeof(int));
	cudaMalloc(&d_out,N*sizeof(int));

	cudaMemcpy(d_elems,host,N*sizeof(int),cudaMemcpyHostToDevice);
	reduceV1<<<(N+BLOCK-1)/BLOCK,BLOCK>>>(d_elems);
	cudaDeviceSynchronize();

	cudaMemcpy(d_elems,host,N*sizeof(int),cudaMemcpyHostToDevice);
	reduceV2<<<(N+BLOCK-1)/BLOCK,BLOCK>>>(d_elems);
	cudaDeviceSynchronize();

	cudaMemcpy(d_elems,host,N*sizeof(int),cudaMemcpyHostToDevice);
	reduceV3<<<(N+BLOCK-1)/BLOCK,BLOCK>>>(d_elems);
	cudaDeviceSynchronize();

	return 0;
}

/*

nvcc hw5_25.cu -o hw5_25cu.out 

*/