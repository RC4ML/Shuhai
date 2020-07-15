
#include <cstdint>
#include <iostream>
#include<fstream>
#include <immintrin.h>
#include<stdlib.h>
#include<string>
#include <unistd.h>
#include <pthread.h>
#include <assert.h>
using namespace std;
__m512i *p;
string path = "./data.txt";
pthread_barrier_t barrier;
long work_group_size = 1024*1024*256;
long op=1000000;
int thread_num = 16;
int burst = 16;
int stride = 64;
long t[20],sum[20];
double sp[20];
void *read(void *thread_index){
	cpu_set_t mask;
	CPU_ZERO(&mask);
	CPU_SET(*(int *)thread_index, &mask);
	assert(!pthread_setaffinity_np(pthread_self(), sizeof(mask), &mask));

	int index = *(int *)thread_index;
	long start = op*stride*index;
	struct timespec time_start={0, 0},time_end={0, 0};
	int sum[burst];
	for(int i=0;i<burst;i++){
		sum[i]=0;
	}
	pthread_barrier_wait(&barrier);
	clock_gettime(CLOCK_REALTIME, &time_start);
		for(int i=0;i<op;i++){
			for(int j=0;j<burst;j++){
				sum[j] += _mm512_reduce_add_epi32(p[(start+i*stride+j)%work_group_size]);
			}
		}
	clock_gettime(CLOCK_REALTIME, &time_end);
	//printf("duration:%llus %lluns\n", time_end.tv_sec-time_start.tv_sec, time_end.tv_nsec-time_start.tv_nsec);
	t[index] =(time_end.tv_sec-time_start.tv_sec)*10e9+ time_end.tv_nsec-time_start.tv_nsec;
	long tp = op*burst*64;
	cout<<tp<<" "<<t[index]<<endl;
	cout<<index<<":"<<(tp*1.0/t[index])<<endl;
	sp[index] = (tp*1.0/t[index]);
}
int main()
{
	
	//float *p=new float[work_group_size];  
	// float *p=(float*)aligned_alloc(64,1000000000*sizeof(float));
	p=(__m512i*)aligned_alloc(64,work_group_size*sizeof(__m512i));
	for(int i=0;i<work_group_size;i++){
		p[i][0]=i;
	}
	ofstream f(path,ios::app);
	int cpu_nums = sysconf(_SC_NPROCESSORS_CONF);


	// int i, tmp[cpu_nums];
	// pthread_t Thread[cpu_nums];
	// pthread_barrier_init(&barrier, NULL, thread_num);
	// for(i = 0; i < thread_num; ++i){
	// 	tmp[i] = i;
	// 	pthread_create(&Thread[i], NULL, read, &tmp[i]);
	// }
	// for(i = 0; i < thread_num; ++i){
	// 	pthread_join(Thread[i],NULL);
	// }
	// long max = 0;
	// for(i = 0; i < thread_num;i++){
	// 	if(max<t[i]){
	// 		max = t[i];
	// 	}
	// }
	// double total_speed=0;
	// for(int i=0;i<thread_num;i++){
	// 	total_speed += sp[i];
	// }
	// double tp = 1.0*op*burst*64*thread_num;
	// f<<"stride:\t"<<stride<<" burst:\t"<<burst<<" \t"<<(tp/max)<<" "<<total_speed<<endl;

	for(int ii=0;ii<11;ii++){
		burst=8;
		for(int jj=0;jj<5;jj++){
			int i, tmp[cpu_nums];
			pthread_t Thread[cpu_nums];
			pthread_barrier_init(&barrier, NULL, thread_num);
			for(i = 0; i < thread_num; ++i){
				tmp[i] = i;
				pthread_create(&Thread[i], NULL, read, &tmp[i]);
			}
			for(i = 0; i < thread_num; ++i){
				pthread_join(Thread[i],NULL);
			}
			long max = 0;
			for(i = 0; i < thread_num;i++){
				if(max<t[i]){
					max = t[i];
				}
			}
			double total_speed=0;
			for(int i=0;i<thread_num;i++){
				total_speed += sp[i];
			}
			double tp = 1.0*op*burst*64*thread_num;
			f<<"stride:\t"<<stride<<" burst:\t"<<burst<<" \t"<<(tp/max)<<" "<<total_speed<<endl;
			//f<<(tp/max)<<endl;
			
			burst*=2;
		}
		stride*=2;
	}
	
	
	
	// for(i = 0; i < thread_num;i++){
	// 	//cout<<sum[i]<<endl;
	// }
	

		// double tp = 1.0*op*burst*64*thread_num;
		// cout<<(tp/max)<<endl;
		// double total_speed=0;
		// for(int i=0;i<thread_num;i++){
		// 	total_speed += sp[i];
		// }
		// cout<<total_speed<<endl;

	
	return 0;
}