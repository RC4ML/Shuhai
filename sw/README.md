
# Build Example Application
1. Install prerequisites, e.g. on Ubuntu install the following packages:
```
$ apt install libboost-program-options-dev cmake
```
2. Compile example application
```
$ cd dma-driver/sw
$ mkdir build && cd build
$ cmake ../src
$ make
```

## Run HBMTest Application/Benchmark
1. Load kernel module if not loaded yet.
```
$ cd dma-driver/driver
$ insmod xdma_driver.ko
```
2. Run the Application (requires root permission)
```
$ cd dma-driver/sw/build
$ ./test-hbm
```

## Read DDRTest Application/Benchmark
1. Load kernel module if not loaded yet.
```
$ cd dma-driver/driver
$ insmod xdma_driver.ko
```
2. Run the Application (requires root permission)
```
$ cd dma-driver/sw/build
$ ./test-ddr
```
