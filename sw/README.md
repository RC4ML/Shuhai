
# Software Part of Shuhai

## 1. Prerequisites
a. Install the following package (cmake) for Ubuntu:
```
$ sudo apt install libboost-program-options-dev cmake
```
b. Make sure you have sudo priority, which is required when installing PCIe kernel and running related application code. 


## 2. Kernel Part
Loading PCIe kernel module if not loaded yet. 
```
$ cd driver
$ make clean
$ make
$ sudo insmod xdma_driver.ko
```
Please make sure your kernel module is successfully installed for Ubuntu.

## 3. Application Part
a. Compile application code
```
$ cd ..
$ mkdir build && cd build
$ cmake ../src
$ make
```
b. Run HBM testing (b1) or DDR4 testing (b2)

b1. Run HBMTest Application/Benchmark
```
$ sudo ./test-hbm
```

b2. Run DDRTest Application/Benchmark
```
$ sudo ./test-ddr
```

## Available parameters:
| Name           |  Value Range for HBM          | Value Range for DDR         | Default Values | Desription                                                                                       |
|----------------|------------------------|---------------------|----------------|--------------------------------------------------------------------------------------------------|
| workGroupSize  | 0x20-0x10000000        | 0x40-0x10000000     | 0x10000000     | Size of the memory region of channels                                                            |
| readEnable     | 0-2^32-1               | 0-2^2-1             | 0              | Read enable Signal of channels,each bit represents a channel,the lowest bit represent channel 0  |
| writeEnable    | 0-2^32-1               | 0-2^2-1             | 0              | Write enable Signal of channels,each bit represents a channel,the lowest bit represent channel 0 |
| latencyChannel | 0-31                   | 0-1                 | closed         | Specify which channel to test latency                                                            |
| strideLength   | 32,64,128,etc          | 64,128,etc          | 64             | Stride length of all channels                                                                    |
| memBurstSize   | 32,64,128,256,512,1024 | 64,128,256,512,1024 | 64             | Memery burst size of all channels                                                                |
| configFile     | fileName               | fileName            | closed         | Use the configurations in the file to modify some specific value                                 |


## configFile
1. configFile can be used to modify a specifig value of a channel.  
for example: ```strideLength 0 128``` means modify the strideLength of channel 0 to 128  

2. the default content in config1.txt is the same with the configuration of fig7.a in our paper   
just run 
```
sudo ./test-hbm --configFile=config1.txt
``` 


3. the default content in config1.txt is the same with the configuration of fig5.a in our paper  
just run 
```
sudo ./test-hbm --configFile=config2.txt
```
