
#include <cstdint>
#include <iostream>
#include <inttypes.h>
#include <unistd.h>
#include <sys/time.h>
#include <iomanip>
#include<fstream>

#include <unistd.h>
#include <pthread.h>
#include <assert.h>

#include <sys/mman.h>
#include <memory.h>
using namespace std;
uint32_t l1,l2, h1,h2;
long *p;
long *index_t;
long * index_temp;
long addr; 
long start;
long c;
int sum;
int *res;
double freq;

string path = "./data.txt";

int stride =32;
int op = 100;

static int64_t rdtsc(void)
{
    unsigned int i, j;
    asm volatile ("rdtsc" : "=a"(i), "=d"(j) : );
    return ((int64_t)j<<32) + (int64_t)i;
}
__inline__ uint64_t perf_counter_asm()
{
	start = addr;
	cout<<addr<<endl;
	cout<<addr+op*8*stride<<endl;
	index_temp = index_t;
	for(int i=0;i<op;i++){
		__asm__ __volatile__ (
		"movq		$0,%rsi\n\t"
		"movq		index_temp,%rcx\n\t"
		"addq		addr,%rsi\n\t"
		"rdtsc\n\t"
		"movl 		%eax,l1\n\t"
		"movl 		%edx,h1\n\t"
		"movq		(%rsi),%rdi\n\t"
		"movq		%rdi,(%rcx)\n\t"
		"mfence\n\t"
		"rdtsc\n\t" 
		"movl 		%eax,l2\n\t"
		"movl 		%edx,h2\n\t"
		"movq 		start,%rdx\n\t"
		"addq		%rdi,%rdx\n\t"
		"movq 		%rdx,addr\n\t"
		
		);
		index_temp=index_temp+1;
		res[i] =((((uint64_t)l2) | (((uint64_t)h2) << 32)) - (((uint64_t)l1) | (((uint64_t)h1) << 32)));
		//cout<<index_temp[0]<<endl;
	}
	cout<<addr<<endl;
	addr = start;
	return 0;
}
__inline__ uint64_t perf_counter()
{
	start = addr;
	cout<<addr<<endl;
	cout<<addr+op*8*stride<<endl;
	struct timespec time_start={0, 0},time_end={0, 0};
	long j=0;
	for(int i=0;i<op;i++){
		clock_gettime(CLOCK_REALTIME, &time_start);
		j = p[j];
		index_t[i] = j; 
		// cout<<j<<endl;
		asm volatile("mfence": : :"memory");
		clock_gettime(CLOCK_REALTIME, &time_end);
		res[i] =(time_end.tv_sec-time_start.tv_sec)*10e9+ time_end.tv_nsec-time_start.tv_nsec;

	}
	cout<<addr<<endl;
	addr = start;
	return 0;
}
void *test_latency(void* i){
	cpu_set_t mask;
	CPU_ZERO(&mask);
	CPU_SET(*(int *)i, &mask);
	assert(!pthread_setaffinity_np(pthread_self(), sizeof(mask), &mask));
	ofstream f(path);
	//ofstream f(path,ios::app);
	long array_size = 0x400000; 
	int *temp;
	
	p=(long*)mmap(NULL, 8*array_size, PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS | 0x40000 /*MAP_HUGETLB*/, -1, 0);
	index_t=(long*)mmap(NULL, 8*op, PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS | 0x40000 /*MAP_HUGETLB*/, -1, 0);
	res = (int*)mmap(NULL, 4*op, PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS | 0x40000 /*MAP_HUGETLB*/, -1, 0);
	if (p == MAP_FAILED) {
		perror("map mem");
		p = NULL;
		return NULL;
	}
	for(int i=0;i<array_size;i++){
		p[i] = 8*(i+stride)%array_size;
	}
	// temp = new int[array_size];
	// for(int i=0;i<array_size;i++){
	// 	temp[i] = i;
	// }
	// int t=0;
	// for(int i=0;i<array_size;i++){
	// 	t+=temp[i];
	// }
	// cout<<"useless:"<<t<<endl;
	int64_t tsc_start, tsc_end;
    struct timeval tv_start, tv_end;
    int usec_delay;

    tsc_start = rdtsc();
    gettimeofday(&tv_start, NULL);
    usleep(100000);
    tsc_end = rdtsc();
    gettimeofday(&tv_end, NULL);

    usec_delay = 1000000 * (tv_end.tv_sec - tv_start.tv_sec) + (tv_end.tv_usec - tv_start.tv_usec);
	freq = (double)((tsc_end-tsc_start) / usec_delay)/1000;
	cout<<freq<<"Ghz\n";

	addr = (long)p;
	perf_counter_asm();
	for(int i=0;i<array_size;i++){
		p[i] = 8*(i+stride)%(array_size);
	}
	int sumup=0;
	// for(int i=array_size-1;i>=0;i--){
	// 	p[i] = 8*(i+stride)%(array_size);
	// }
	
	for(int i=0;i<op;i++){
		sumup+=res[i];
		sumup+=index_t[i];
	}
	perf_counter_asm();

	int cycles = 0;
	for(int i=0;i<op;i++){
		cycles+=res[i];
		f<<fixed<<setprecision(2);
		f<<(res[i])<<endl;
	}
	cout<<sumup<<endl;
	sumup=0;
	for(int i=0;i<op;i++){
		sumup+=index_t[i];
	}
	cout<<"total:"<<sumup<<endl;
	cout<<cycles;
}
int main()
{
	int cpu_nums = sysconf(_SC_NPROCESSORS_CONF);
	int i, tmp[cpu_nums];
	pthread_t Thread[cpu_nums];
	i=5;
	tmp[i] = i;
	pthread_create(&Thread[i], NULL, test_latency, &tmp[i]);
	pthread_join(Thread[i],NULL);
	// for(i = 0; i < cpu_nums; ++i){
	// 	tmp[i] = i;
	// 	pthread_create(&Thread[i], NULL, fun, &tmp[i]);
	// }
 
	// for(i = 0; i < cpu_nums; ++i)
	// 	pthread_join(Thread[i],NULL);
	cout<<sizeof(long);
	//sleep(5);
	return 0;
}