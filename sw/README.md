
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

## Read DDRTest Application/Benchmark
1. Load kernel module if not loaded yet.
```
$ cd ../driver
$ sudo insmod xdma_driver.ko
```
2. Run the Application (requires root permission)
```
$ cd ../build
$ sudo ./test-ddr
```
