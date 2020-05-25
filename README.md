# Shuhai
Shuhai is a benchmarking-memory tool that allows FPGA programmers to demystify all the underlying details of memories, e.g., HBM and DDR4, on a Xilinx FPGA. 
### Two Reasons Why We Need Shuhai? 
First, in terms of benchmarking memory, it can be done better on FPGA, rather than on CPU/GPU. 
In particular, when benchmarking memory on cpu or gpu, we cannot get rid of the negative effect of cache/TLB in CPUs/GPUs. So there is a lot of work about benchmarking cache in CPUs/GPUs, rather than directly benchmarking memory. 
In contrast, when benchmarking memory on the FPGA, the benchmarking engine can directly attach to the memory such that there is no noise between memory and benchmarking engine.

Second, we do not need to reinvent the wheel again for each memory/FPGA. With Shuhai, before implementing the concrete application that contains a particular memory access pattern on the FPGA, we are able to benchmark the corresponding memory access pattern to make sure that the memory side will not be the bottleneck. In case it is, the authors need to tune the implementation to have a more efficient memory access pattern such that your application will not be bound by memory. 


## 1. Getting Started
```
$ git clone https://github.com/RC4ML/Shuhai.git
$ git submodule update --init --recursive
```

## 2. Build FPGA Project
```
$ cd hw/
```
According to hw/README.md, build vivado project and program the FPGA with the generated bitstream. 

## 3. Build Software Project
```
$ cd sw/
```
According to sw/README.md, build the software project and run the application
