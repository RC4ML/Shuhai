# include <stdio.h>
# include <stdint.h>

# include "cuda_runtime.h"

//compile nvcc *.cu -o test

__global__ void global_latency (unsigned int * my_array, int array_length, int iterations,  unsigned int * duration, unsigned int *index);


void parametric_measure_global(int N, int iterations);

void measure_global();


int main(){

	cudaSetDevice(1);

	measure_global();

	cudaDeviceReset();
	return 0;
}


void measure_global() {

	int N, iterations; 
	//stride in element
	iterations = 1;
	
	N = 20*256*1024; 
	// N = 96*1024;
		printf("\n=====%10.4f MB array, Fermi pattern read, read 160 element====\n", sizeof(unsigned int)*(float)N/1024/1024);
		parametric_measure_global(N, iterations);
		printf("===============================================\n\n");
	
}


void parametric_measure_global(int N, int iterations) {
	cudaDeviceReset();

	cudaError_t error_id;
	
	int i;
	unsigned int * h_a;
	/* allocate arrays on CPU */
	h_a = (unsigned int *)malloc(sizeof(unsigned int) * (N+2));
	unsigned int * d_a;
	/* allocate arrays on GPU */
	error_id = cudaMalloc ((void **) &d_a, sizeof(unsigned int) * (N+2));
	if (error_id != cudaSuccess) {
		printf("Error 1.0 is %s\n", cudaGetErrorString(error_id));
	}


   	/* initialize array elements*/
	for (i=0; i<N; i++) 
		h_a[i] = 0;
	// // 16MB*33 
	// for (i=0; i<33; i++){ 
	// 	h_a[i * 1024 * 256 * 16*2] = (i+1)*256*1024*16*2;
	// 	h_a[i * 1024 * 256 * 16*2+1] = (1+i) * 1024 * 256 * 16*2+1;
	// 	}
	// // 1MB*63
	// for (i=0; i<63 ; i++){
	// 	h_a[(528*2+i)*256*1024] = (528*2+1+i)*256*1024;
	// }
	// h_a[528*2*256*1024+1] = 528*2*256*1024+2;
	// h_a[528*2*256*1024+2] = 528*2*256*1024+3;
	// h_a[528*2*256*1024+3] = 528*2*256*1024+1;
	// h_a[591*256*1024 ] = 1;
	
	// for (i=0; i<iterations*160; i++){ 
	// 	h_a[i ] = (i+1);
	// 	// h_a[i * 16+1] = (1+i) * 16+1;
	// 	}
	for (i=0; i<N ; i++){
		h_a[i] = (i+1024*16)%N;
	}	

	h_a[N] = 0;
	h_a[N+1] = 0;
	/* copy array elements from CPU to GPU */
        error_id = cudaMemcpy(d_a, h_a, sizeof(unsigned int) * N, cudaMemcpyHostToDevice);
	if (error_id != cudaSuccess) {
		printf("Error 1.1 is %s\n", cudaGetErrorString(error_id));
	}


	unsigned int *h_index = (unsigned int *)malloc(sizeof(unsigned int)*160*2);
	unsigned int *h_timeinfo = (unsigned int *)malloc(sizeof(unsigned int)*160*2);

	unsigned int *duration;
	error_id = cudaMalloc ((void **) &duration, sizeof(unsigned int)*160*2);
	if (error_id != cudaSuccess) {
		printf("Error 1.2 is %s\n", cudaGetErrorString(error_id));
	}


	unsigned int *d_index;
	error_id = cudaMalloc( (void **) &d_index, sizeof(unsigned int)*160*2 );
	if (error_id != cudaSuccess) {
		printf("Error 1.3 is %s\n", cudaGetErrorString(error_id));
	}





	cudaThreadSynchronize ();
	/* launch kernel*/
	dim3 Db = dim3(1);
	dim3 Dg = dim3(1,1,1);


	global_latency <<<Dg, Db>>>(d_a, N, iterations,  duration, d_index);

	cudaThreadSynchronize ();

	error_id = cudaGetLastError();
        if (error_id != cudaSuccess) {
		printf("Error kernel is %s\n", cudaGetErrorString(error_id));
	}

	/* copy results from GPU to CPU */
	cudaThreadSynchronize ();



        error_id = cudaMemcpy((void *)h_timeinfo, (void *)duration, sizeof(unsigned int)*160*2, cudaMemcpyDeviceToHost);
	if (error_id != cudaSuccess) {
		printf("Error 2.0 is %s\n", cudaGetErrorString(error_id));
	}
        error_id = cudaMemcpy((void *)h_index, (void *)d_index, sizeof(unsigned int)*160*2, cudaMemcpyDeviceToHost);
	if (error_id != cudaSuccess) {
		printf("Error 2.1 is %s\n", cudaGetErrorString(error_id));
	}

	cudaThreadSynchronize ();

	for(i=0;i<iterations*160;i++)
		printf("%d\t %d\n", h_index[i], h_timeinfo[i]);

	/* free memory on GPU */
	cudaFree(d_a);
	cudaFree(d_index);
	cudaFree(duration);


        /*free memory on CPU */
        free(h_a);
        free(h_index);
	free(h_timeinfo);
	
	cudaDeviceReset();	

}



__global__ void global_latency (unsigned int * my_array, int array_length, int iterations, unsigned int * duration, unsigned int *index) {

	unsigned int start_time, end_time;
	unsigned int j = 0; 

	__shared__ unsigned int s_tvalue[2*160];
	__shared__ unsigned int s_index[2*160];

	int k;
	int temp;

	for(k=0; k<iterations*160; k++){
		s_index[k] = 0;
		s_tvalue[k] = 0;
	}

	//first round
	for (k = 0; k < array_length; k++){
		temp += my_array[k];		
	} 
	index[2*160] = temp;	
	
	//second round 
	for (k = 0; k < iterations*160; k++) {
		
			start_time = clock();

			j = my_array[j];
			s_index[k]= j;
			end_time = clock();

			s_tvalue[k] = end_time-start_time;

	}

	my_array[array_length] = j;
	my_array[array_length+1] = my_array[j];

	for(k=0; k<iterations*160; k++){
		index[k]= s_index[k];
		duration[k] = s_tvalue[k];
	}
}



