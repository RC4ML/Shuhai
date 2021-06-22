
# Software Part of Shuhai

## 1. Prerequisites
#### a. Install the following package (cmake) for Ubuntu:
```
$ sudo apt install libboost-program-options-dev cmake
```
#### b. Make sure you have sudo priority, which is required when installing PCIe kernel and running related application code. 


## 2. Setup Hugepages
#### a. Create a group for users of hugepages, and retrieve its GID (in this example, 1001) then add yourself to the group.
```
$ sudo groupadd hugetlbfs

$ sudo getent group hugetlbfs

$ sudo adduser dasidler hugetlbfs
```

#### b. Edit `/etc/sysctl.conf` and add this text to specify the number of pages you want to reserve (see page-size)
```
# Allocate 8192*2MiB for HugePageTables
vm.nr_hugepages = 8192

# Members of group hugetlbfs(1001) can allocate "huge" shared memory segments
vm.hugetlb_shm_group = 1001
```
#### c. Create a mount point for the file system
```
$ mkdir /media/huge
```

#### d. Add this line in `/etc/fstab` (The mode 1770 allows anyone in the group to create files but not unlink or rename each other's files.)
```
# hugetlbfs
hugetlbfs /media/huge hugetlbfs mode=1770,gid=1001 0 0
```

#### e. Reboot

#### f. Add the following line to `/etc/security/limits.conf` to configure the amount of memory a user can lock, so an application can't crash your operating system by locking all the memory. 
```
@hugetlbfs	hard	memlock		1048576
```



## 3. Kernel Part
Loading PCIe kernel module if not loaded yet. 
```
$ cd driver
$ make clean
$ make
$ sudo insmod xdma_driver.ko
```
Please make sure your kernel module is successfully installed for Ubuntu.






## 4. Application Part
#### a. Compile application code
```
$ cd ..
$ mkdir build && cd build
$ cmake ../src
$ make
```
#### b. Run HBM testing or DDR4 testing with parameters specified in the "config" file (shown in 3.c).
```
$ sudo ./test-hbm --configFile=config.txt
$ sudo ./test-ddr --configFile=config.txt
```
If configFile is not specified, the parameters are loaded with default values.
| Name           |  Value Range for HBM          | Value Range for DDR         | Default Values | Desription                                                                                       |
|----------------|------------------------|---------------------|----------------|--------------------------------------------------------------------------------------------------|
| workGroupSize  | 0x20-0x10000000        | 0x40-0x10000000     | 0x10000000     | Working set size                                                            |
| readEnable     | 0-2^32-1               | 0-2^2-1             | 0              | Read enable Signal, each bit represents a channel, the lowest bit represents the channel 0  |
| writeEnable    | 0-2^32-1               | 0-2^2-1             | 0              | Write enable Signal, each bit represents a channel,the lowest bit represents the channel 0 |
| latencyChannel | 0-31                   | 0-1                 | closed         | Specify which channel to test latency                                                            |
| strideLength   | 32,64,128,etc          | 64,128,etc          | 64             | Stride length                                                                    |
| memBurstSize   | 32,64,128,256,512      | 64,128,256,512,1024 | 64             | Memery burst size                                                                |


#### c. Format of "config" file
Each line in the "config" file refers to a parameter reconfiguration, whose format is ```parameter channel value```, where  

```parameter``` illustrates the exact parameter you want to reconfig,

```channel``` illustrates the exact AXI channel you want to reconfig the ```parameter```, and

```value``` illustrates the exact value you want to set the ```parameter```.

For example, for example: ```strideLength 0 128``` means the strideLength of the AXI channel 0 is set to 128.

##### Two examples used  in our paper. 
The configuration file "config1.txt" is associated with Fig 7.a in our paper   
```
sudo ./test-hbm --configFile=config1.txt
``` 

The configuration file "config2.txt" is associated with Fig 5.a in our paper   
```
sudo ./test-hbm --configFile=config2.txt
``` 

