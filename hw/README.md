# Hardware Part of Benchmarking (Build project)


1. Create build directory
```
$ mkdir build
$ cd build
```

2. a) Configure HBM project build
```
$ cmake .. -DMEMORY_NAME=hbm -DHBM_MAPPING=DEFAULT 

```
2. b)Alternatively Configure DDR project build
```
$ cmake .. -DMEMORY_NAME=ddr -DDDR_MAPPING=RCBI 

```

All options:
| Name                  | Values                       | Desription                                           |
|-----------------------|------------------------------|------------------------------------------------------|
| MEMORY_NAME           | <hbm,ddr>                    | Supported memory device                              |
| HBM_MAPPING           | <DEFAULT,RBC,BRC,RCB,BRGCG>  | HBM memory mapping, Default: DEFAULT                 |
| DDR_MAPPING           | <BRC,RBC,RCB,RCBI>           | DDR memory mapping, Default: RCBI                    |


3. Create vivado project
```
$ make project
```

4. Run synthesis
```
$ make synthesize
```

5. Run implementation
```
$ make implementation
```

6. Generate bitstream
```
$ make bitstream
```
