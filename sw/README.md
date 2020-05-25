
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
a. Compile example application
```
$ cd ..
$ mkdir build && cd build
$ cmake ../src
$ make
```
b. Run HBM testing (b1) or DDR4 testing (b2)

b1. Run HBMTest Application/Benchmark
```
$ sudo ./test-hbm --workGroupSize=40
```

b2. Run DDRTest Application/Benchmark
```
$ sudo ./test-ddr --workGroupSize=40
```


Available flags:
| Name                  |Values HBM| Values  DDR                     | Desription                                           |
|-----------------------|--------|------------------------------|------------------------------------------------------|
| workGroupSize         |0x20-0x10000000| 0x40-0x10000000                    | Size of the memory region of 32 channels                              |
| readEnable            |0-2^32-1| 0-2^2-1                     | Read enable Signal of 2 channels,each bit represents a channel,the lowest bit represent channel 0                 |
| writeEnable           |0-2^32-1| 0-2^2-1                    | Write enable Signal of 2 channels,each bit represents a channel,the lowest bit represent channel 0                 |
| channel           |0-31| 0-1           | Specify which channel to test latency, and it will automatically set the latency_test_enable to 1                    |
| strideLength      |32,64,128,etc| 64,128,etc           | Stride length of all channels                    |
| memBurstSize      |32,64,128,256,512,1024| 64,128,256,512,1024           | Memery burst size of all channels                    |
| configFile      |fileName| fileName           | use the configurations in the file to modify some specific value                  |

3. Default setting  
if you only run ```sudo ./test-hbm ``` or ```sudo ./test-ddr```, the settings will be default values

| Name                  | Default Values                       |
|-----------------------|------------------------------|
|workGroupSize          |0x10000000                    |
|strideLength           |64                    |
|memBurstSize           |64                    |
|readEnable             |0                    |
|writeEnable            |0                    |
|channel                |0                    |
|latency_test_enable    |0                    |


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
