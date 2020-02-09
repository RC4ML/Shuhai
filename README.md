# benchmarking HBM & DDR

## Getting Started

### Prerequisites
- Xilinx Vivado 2019.2
- cmake 3.0 or higher

Supported boards 
- Xilinx Alveo U280

## Build project

1. Initialize submodules
```
$ git clone https://github.com/FPGAML/Benchmarking-HBM-DDR.git
$ git submodule update --init --recursive
```

2. Install xdma driver
```
$ cd driver/

```
read driver/README.md and install xdma driver 

3. Build hardware project
```
$ cd hw/
```

read hw/README.md, build vivado project and program bitstream

4. Reboot

5. Build software project
```
$ cd sw/
```
read sw/README.md, build software project and run
