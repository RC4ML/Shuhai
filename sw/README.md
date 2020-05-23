
# Build Example Application
1. Install prerequisites, e.g. on Ubuntu install the following packages:
```
$ sudo apt install libboost-program-options-dev cmake
```
2. Compile example application
```

$ mkdir build && cd build
$ cmake ../src
$ make
```

## Run HBMTest Application/Benchmark
1. Load kernel module if not loaded yet.
```
$ cd ../driver
$ sudo insmod xdma_driver.ko
```
2. Run the Application (requires root permission)
```
$ cd ../build
$ sudo ./test-hbm
```
Available flags:
| Name                  | Values                       | Desription                                           |
|-----------------------|------------------------------|------------------------------------------------------|
| workGroupSize         | 0x20-0x10000000                    | Size of the memory region of 32 channels                              |
| readEnable            | 0-2^32-1                     | Read enable Signal of 32 channels,each bit represents a channel,the lowest bit represent channel 0                 |
| writeEnable            | 0-2^32-1                    | Write enable Signal of 32 channels,each bit represents a channel,the lowest bit represent channel 0                 |
| channel           | 0-31           | Specify which channel to test latency                    |
| strideLength      | 32,64,128,etc           | Stride length of all channels                    |
| memBurstSize      | 32,64,128,256,512,1024           | Memery burst size of all channels                    |
| configEnable      | 0,1           | 1 means using config.txt to modify some specific value of a channel                    |

## Run DDRTest Application/Benchmark
1. Load kernel module if not loaded yet.
```
$ cd ../driver
$ sudo insmod xdma_driver.ko
```
2. Run the Application (requires root permission)
```
$ cd ../build
$ sudo ./test-ddr --workGroupSize 40
```

Available flags:
| Name                  | Values                       | Desription                                           |
|-----------------------|------------------------------|------------------------------------------------------|
| workGroupSize         | 0x40-0x10000000                    | Size of the memory region of 32 channels                              |
| readEnable            | 0-2^2-1                     | Read enable Signal of 2 channels,each bit represents a channel,the lowest bit represent channel 0                 |
| writeEnable            | 0-2^2-1                    | Write enable Signal of 2 channels,each bit represents a channel,the lowest bit represent channel 0                 |
| channel           | 0-1           | Specify which channel to test latency                    |
| strideLength      | 64,128,etc           | Stride length of all channels                    |
| memBurstSize      | 64,128,256,512,1024           | Memery burst size of all channels                    |
| configEnable      | 0,1           | 1 means using config.txt to modify some specific value of a channel                    |

config.txt can be used to modify a specifig value of a channel  
for example: strideLength 0 128 means modify the strideLength of channel 0 to 128
