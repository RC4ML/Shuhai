/*
 *
 * globalCopy.cu
 *
 * Microbenchmark for copy bandwidth of global memory.
 *
 * Build with: nvcc -I ../chLib <options> globalCopy.cu
 * Requires: No minimum SM requirement.
 *
 * Copyright (c) 2011-2012, Archaea Software, LLC.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions 
 * are met: 
 *
 * 1. Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in 
 *    the documentation and/or other materials provided with the 
 *    distribution. 
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include "cuda_runtime.h"
#include "sys/time.h"

//SM number: 8(Fermi 560 Ti); 12(Kepler 780 ); 16 (Maxwell 980)
#define BLOCK_BASE (64)
#define MULTIPLIER (10)

template<const int b,const int s> 
__global__ void GlobalCopy(int *out, const int *in, size_t N )
{
    int temp[16];

	//avoid accessing cache, assure cold-cache access
	int start = s*((blockIdx.x * blockDim.x + threadIdx.x)/b) + (blockIdx.x * blockDim.x + threadIdx.x)%b;
    int step = s * (blockDim.x * gridDim.x / b);
    // int step = 16 ;

    // printf("start:%d\n",step);
	int i;

    for ( i = start; i < N; i += step*16 ) {
        for ( int j = 0; j <16; j++ ) {
            // int index = i;//+j*blockDim.x;;
            temp[j] += in[i + j*step];
        }
        // for ( int j = 0; j < n; j++ ) {
        //     int index = i+j*blockDim.x;;
            
            // if(threadIdx.x == 1){
            //     printf("start:%d\n",i);
            // }
        // }
    }
    for(int j=0;j<16;j++){
        out[j] = temp[j];
    }
    
    //there may be some elements left due to misaligning.
    // for ( int j = 0; j < n; j++ ) {
    //     for ( int j = 0; j < n; j++ ) {
	// 		int index = i + j;
    //         if ( index<N ) temp[j] = in[index];
    //     }
    //     for ( int j = 0; j < n; j++ ) {
	// 		int index = i + j;
    //         if ( index<N ) out[index] = temp[j];
    //     }
    // }
}

template<const int b,const int s>
double BandwidthCopy( int *deviceOut, int *deviceIn,
               int *hostOut, int *hostIn,
               size_t N,
               int cBlocks, int cThreads )
{
    double ret = 0.0;
    double elapsedTime;
    int cIterations;
    cudaError_t status;
    int W = N/(cBlocks*cThreads);

    // printf("w:%d\n",W);
    for ( int i = 0; i < N; i++ ) {
        int r = rand();
		hostIn[i] = *(int *)(&r); // for small ints, LSBs; for int2 and int4, some stack cruft
    }

	memset(hostOut, 0, N*sizeof(int));
	cudaMemcpy(deviceIn, hostIn, N*sizeof(int), cudaMemcpyHostToDevice);
	cudaThreadSynchronize();
    {
        // confirm that kernel launch with this configuration writes correct result
        GlobalCopy<b,s><<<cBlocks,cThreads>>>( 
            deviceOut,
            deviceIn,
            N );
		cudaThreadSynchronize();
		cudaMemcpy(hostOut, deviceOut, N*sizeof(int), cudaMemcpyDeviceToHost);
		cudaThreadSynchronize();
        status = cudaGetLastError() ;       
		// if (memcmp(hostOut, hostIn, (N)*sizeof(int))) {
        //     printf( "Incorrect copy performed!\n" );
        //     goto Error;
        // }

    }

    cIterations = 4;
    struct timeval start, end;
    gettimeofday(&start,NULL);
	//time_t start, end;
	//start = clock();

    for ( int i = 0; i < cIterations; i++ ) {
		GlobalCopy<b,s> << <cBlocks, cThreads >> >(deviceOut, deviceIn, N);
    }

    cudaThreadSynchronize();
    // make configurations that cannot launch error-out with 0 bandwidth
	status = cudaGetLastError();
    gettimeofday(&end,NULL);
    //end = clock();

    //elapsedTime =  (end - start)/1000.0;
    elapsedTime =  end.tv_sec - start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;

    // bytes per second
	ret = ((double) b*N/s*cIterations*sizeof(int)) / elapsedTime;
    // gigabytes per second
    ret /= 1024.0*1048576.0;

Error:
    return ret;
}

template<const int b,const int s>
double ReportRow( size_t N, size_t threadStart, size_t threadStop, size_t cBlocks)
{
    int *deviceIn = 0;
	int *deviceOut = 0;
	int *hostIn = 0;
	int *hostOut = 0;

    cudaError_t status;

    int maxThreads = 0;
    double maxBW = 0.0;

	cudaMalloc(&deviceIn, N*sizeof(int));
	cudaMalloc(&deviceOut, N*sizeof(int));
	cudaMemset(deviceOut, 0, N*sizeof(int));

	hostIn = new int[N];
	hostOut = new int[N];
	if (!hostIn || !hostOut){
		if (hostIn) delete[] hostIn;
		if (hostOut) delete[] hostOut;

		cudaFree(deviceIn);
		cudaFree(deviceOut);
		return maxBW;
	}

    printf( "%d\t", b );

    for ( int cThreads = threadStart; cThreads <= threadStop; cThreads *= 2 ) {
        double bw = BandwidthCopy<b,s>(
            deviceOut, deviceIn, hostOut, hostIn, N,
             cBlocks, cThreads );
        if ( bw > maxBW ) {
            maxBW = bw;
            maxThreads = cThreads;
        }
        printf( "%.2f\t", bw );
    }
    printf( "%.2f\t%d\n", maxBW, maxThreads );

	delete[] hostIn;
	delete[] hostOut;

	cudaFree(deviceIn);
	cudaFree(deviceOut);
	return maxBW;
}

int main()
{
    int device = 0;
    int size = 64;
	int N = size * 1024*1024*8;
	int block_num;
	int threadStart = 128;
	int threadStop = 128;

    printf( "Using coalesced reads and writes\n" );
	cudaSetDevice(device);
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, device);

	printf("\nDevice %d: \"%s\"\n", device, deviceProp.name);
	for ( block_num =int(BLOCK_BASE); block_num <= int(BLOCK_BASE); block_num = block_num*2 ){
		printf("\n=================Block number: %d=================\n", block_num);
		printf("Operand size: %d byte%c\n", sizeof(int), sizeof(int) == 1 ? '\0' : 's');
		printf("Input size: %dM operands\n", (int)(N >> 20));
		printf("                      Block Size\n");
		printf("Unroll\t");

		for (int cThreads = threadStart; cThreads <= threadStop; cThreads *= 2) {
			printf("%d\t", cThreads);
		}

		printf("maxBW\tmaxThreads\n");
		ReportRow<16,256>(N, threadStart, threadStop, block_num);
		ReportRow<32,256>(N, threadStart, threadStop, block_num);
		ReportRow<64,256>(N, threadStart, threadStop, block_num);
		ReportRow<128,256>(N, threadStart, threadStop, block_num);
		// ReportRow<8>(N, threadStart, threadStop, block_num);

    }
    return 0;
}
