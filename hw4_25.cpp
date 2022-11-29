
#include <stdio.h>
#include <stdlib.h>     
#include<time.h>
#include<omp.h>
#define N 100000

void compress_ccode(int *h_in, int *h_out, int arrsize){
  int j =0; 
  int start = 0 ,end = 0;
  for(int i = 0; i< arrsize ; i++ ){
    if (h_in[i] == 1 && start == 0) {
      start = i+1;
    }
    if (h_in[i] == 0 && start != 0){
      end = i+1 - start;
      h_out[j] = start; 
      j=j+1; 
      h_out[j] = end;
      j=j+1;
      start = 0; 
      end = 0 ;
    }
  }
}

void decompress_ccode(int *h_in,int *h_out, int arrsize){
  int j = 0; 

  for(int a = 0; a < arrsize ; a++){
        h_out[a] = 0;}

  for(int i = 0; i<arrsize ; i = i + 2 ){
    for(int j = h_in[i]-1 ; j< h_in[i]+h_in[i+1]-1; j++ ){
      h_out[j] = 1;}
   }
}

int main(){
  int arr[N];
  int *h_in, *h_out, *h_outf;
  h_in = (int *)malloc(sizeof(int)* N);
  h_out = (int *)malloc(sizeof(int)* N);
  h_outf = (int *)malloc(sizeof(int)* N);
	clock_t start,stop;
	start=clock();

  for(int a = 0; a < N ; a++){
        h_in[a] = rand() % 2 ;}
  

  /////// input list //////////
  //printf("\ninput matrix: \t\t",N);
  for(int a = 0; a < N ; a++){
      //printf(" %d",h_in[a]) ;
  }

  //// CPU code ////
  compress_ccode(h_in, h_out, N);

  //printf("\n\ncompressed matrix: \t");
  for(int a = 0; a < N ; a++){
    //if (h_out[a] != 0)
      //printf(" %d",h_out[a]) ;
  }
 
  decompress_ccode(h_out, h_outf, N);
  
  //printf("\n\ndecompressed matrix: \t");
  for(int a = 0; a < N ; a++){
    //printf(" %d",h_outf[a]); 
  }

  stop=clock();
  
  printf("\nsize of N %d\n", N);
  printf("\nTime taken in CPU  %lf\n", (double)(stop-start)/CLOCKS_PER_SEC);
	
  printf("\n ");
return 0;
}

/*

g++ hw4_25.cpp -o hw4_25cpp.out
./hw4_25cpp.out

*/

