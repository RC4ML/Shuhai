# Shuhai
Shuhai is a benchmarking-memory tool that allows FPGA programmers to demystify all the underlying details of memories, e.g., HBM and DDR4, on a Xilinx FPGA. 
### Two Reasons Why We Need Shuhai? 
First, in terms of benchmarking memory, it can be done better on FPGA, rather than on CPU/GPU. 
In particular, when benchmarking memory on cpu/gpu, we cannot get rid of the negative effect of cache/TLB. So there is a lot of work about benchmarking cache in CPUs/GPUs, rather than directly benchmarking memory. 
In contrast, when benchmarking memory on an FPGA, the benchmarking hardware engine can directly attach to the memory such that there is no noise between the targeted memory and the benchmarking engine.

Second, we do not need to reinvent a wheel again for each memory/FPGA. With Shuhai, before implementing the concrete application that contains a particular memory access pattern on the FPGA, we are able to benchmark the corresponding memory access pattern to make sure that the memory side will not be the bottleneck. In case it is, the authors need to tune the implementation to have a more efficient memory access pattern such that your application will not be bound by memory. 


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


## Frequently Asked Questions
1, Q. the machine failed to detect PCIe on the FPGA when loading the kernel module.
   A. Connect the JTAG to another machine that will not crash when downloading the FPGA image. It means that you cannot use the same machine to load the bitstream. 


## Cite this work
If you use it in your paper, please cite our work ([full version](https://ieeexplore.ieee.org/document/9114755)).
```
@inproceedings{wang_fccm20,
  title={Shuhai: Benchmarking High Bandwidth Memory On FPGAs},
  author={Zeke Wang and Hongjing Huang and Jie Zhang and Gustavo Alonso},
  year={2020},
  booktitle={IEEE 28th Annual International Symposium on Field-Programmable Custom Computing Machines (FCCM)},
}

```
### Related publications
* Zeke Wang, Hongjing Huang, Jie Zhang, Gustavo Alonso. [Shuhai: Benchmarking High Bandwidth Memory On FPGAs](https://wangzeke.github.io/doc/shuhai_fccm_20.pdf). FCCM, 2020.


