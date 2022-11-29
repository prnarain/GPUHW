
#include <stdio.h>
#include <stdlib.h>     
#include<time.h>
#include<omp.h>

#define N 10000000

void encrypt_ccode(char *h_in, char *h_out, int arrsize){
  int out; int ii;
  for (int i = 0; i< arrsize; i=i+8){
    #pragma omp parallel
    {
      int j = omp_get_thread_num();
      out = h_in[i+j] + (i+j+1) + 1 ; 
      if (out > 122) 
        out = (out - 123)%26 + 97 ; 
      h_out[i+j] = out;
    }
  }
}

void decrypt_ccode(char *h_in, char *h_out, int arrsize){
  int out; 
  for(int a = 0; a < arrsize ; a++){h_out[a] = 0;}
  //#pragma omp parallel
  for (int i = 0; i< arrsize; i=i+8){
    #pragma omp parallel
    {
      int j = omp_get_thread_num();
      out = h_in[i+j] - (i+j+1) - 1 ;
      if (out  < 97) 
        out = 122 - (96-out)%26   ; 
      h_out[i+j] = out;
    }
  }
}

int main(){

  clock_t start, end; 
  char *h_in, *h_out, *h_outf;
  h_in = (char *)malloc(sizeof(int)* N);
  h_out = (char *)malloc(sizeof(int)* N);
  h_outf = (char *)malloc(sizeof(int)* N);
  start = clock ();
  for(int a = 0; a < N ; a++){
    h_in[a] = "abcdefghijklmnopqrstuvwxyz"[random () % 26] ;}
  
  //// CPU code ////
  encrypt_ccode(h_in, h_out, N);
  
  decrypt_ccode(h_out, h_outf, N);
  
  //printf(" IP \t ENC \t DEC \t\t",N);
  //printf("\n----    ----    ----\n");
  for(int a = 0; a < N ; a++){
    //printf("\n%d \t %d \t %d ",h_in[a], h_out[a], h_outf[a]) ;
    //printf(" %c \t %c \t %c \n",h_in[a], h_out[a], h_outf[a]) ;
  }
  end = clock();
  printf("\nsize of N %d", N);
  printf("\ntotal time taken %lf\n", (double)(end-start)/(double)CLOCKS_PER_SEC);
return 0;
}

/*

g++ hw3_25pl.cpp -o hw3_25plcpp.out -fopenmp 
export OMP_NUM_THREADS=8
./hw3_25plcpp.out

*/