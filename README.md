# benchmarking HBM & DDR

## Build project

1. Initialize submodules
```
$ git clone
$ git submodule update --init --recursive
```

2. Create build directory
```
$ mkdir build
$ cd build
```

3. a) Configure HBM project build
```
$ cmake .. -DMEMORY_NAME=hbm -DHBM_MAPPING=DEFAULT 

```
3. b)Alternatively Configure DDR project build
```
$ cmake .. -DMEMORY_NAME=ddr -DDDR_MAPPING=RCBI 

```
All options:
| Name                  | Values                       | Desription                  |
| MEMORY_NAME           | <hbm,ddr>                    | Supported memory device     |
| HBM_MAPPING           | <DEFAULT,RBC,BRC,RCB,BRGCG>  | Default: DEFAULT            |
| DDR_MAPPING           | <BRC,RBC,RCB,RCBI>           | Default: RCBI               |

4. Create vivado project
```
$ make project
```

5. Run synthesis
```
$ make synthesize
```

6. Run implementation
```
$ make implementation
```

7. Generate bitstream
```
$ make bitstream
```