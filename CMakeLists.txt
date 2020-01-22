# Author:   Huang hongjing (21515069@zju.edu.cn)

cmake_minimum_required(VERSION 3.0)

project(benchmarking-example)

# Include custom Find<Module>.cmake scripts to enable searching for Vivado HLS                                
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)  

# Check if parent directory
get_directory_property(hasParent PARENT_DIRECTORY)

if (DEFINED ENV{IPREPO_DIR})
   set(IPREPO_DIR $ENV{IPREPO_DIR})
elseif (NOT IPREPO_DIR)
   set(IPREPO_DIR ${CMAKE_CURRENT_SOURCE_DIR}/iprepo)
   message("set iprepor dir ${IPREPO_DIR}")
endif()

# set(DEVICE_NAME
if (NOT DEFINED MEMORY_NAME)
   set(MEMORY_NAME hbm)
endif()

if (MEMORY_NAME STREQUAL "hbm")
   set(DEVICE_MEMORY u280_hbm)
elseif(MEMORY_NAME STREQUAL "ddr")
   set(DEVICE_MEMORY u280_ddr)
endif()


if (NOT DEFINED DDR_MAPPING)
   set(DDR_MAPPING RCB)
endif()

if (DDR_MAPPING STREQUAL "BRC")
   set(DDR_MAPPING_MODE BANK_ROW_COLUMN)
elseif(DDR_MAPPING STREQUAL "RBC")
   set(DDR_MAPPING_MODE ROW_BANK_COLUMN)
elseif(DDR_MAPPING STREQUAL "RCB")
   set(DDR_MAPPING_MODE ROW_COLUMN_BANK)
elseif(DDR_MAPPING STREQUAL "RCBI")
   set(DDR_MAPPING_MODE ROW_COLUMN_BANK_INTLV)
endif()



if (NOT DEFINED HBM_MAPPING)
   set(HBM_MAPPING DEFAULT)
endif()

if (HBM_MAPPING STREQUAL "DEFAULT")
   set(HBM_MAPPING_MODE DEFAULT)
elseif(HBM_MAPPING STREQUAL "RBC")
   set(HBM_MAPPING_MODE RBC)
elseif(HBM_MAPPING STREQUAL "BRC")
   set(HBM_MAPPING_MODE BRC)
elseif(HBM_MAPPING STREQUAL "RCB")
   set(HBM_MAPPING_MODE RCB)
elseif(HBM_MAPPING STREQUAL "BRGCG")
   set(HBM_MAPPING_MODE BRGCG)
endif()


###VIVADO project
# Find Xilinx Vivado
find_package(Vivado REQUIRED)
if (NOT VIVADO_FOUND)
   message(FATAL_ERROR "Vivado not found.")
endif()



configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_prj.tcl.in ${CMAKE_BINARY_DIR}/create_project.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_DEFAULT.tcl ${CMAKE_BINARY_DIR}/create_hbm_DEFAULT.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_BRC.tcl ${CMAKE_BINARY_DIR}/create_hbm_BRC.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_BRGCG.tcl ${CMAKE_BINARY_DIR}/create_hbm_BRGCG.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_RBC.tcl ${CMAKE_BINARY_DIR}/create_hbm_RBC.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_RCB.tcl ${CMAKE_BINARY_DIR}/create_hbm_RCB.tcl)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/run_synthesis.tcl.in ${CMAKE_BINARY_DIR}/run_synthesis.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/run_implementation.tcl.in ${CMAKE_BINARY_DIR}/run_implementation.tcl)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/scripts/generate_bitstream.tcl.in ${CMAKE_BINARY_DIR}/generate_bitstream.tcl)

set (PROJECT_DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_prj.tcl.in
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_DEFAULT.tcl
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_BRC.tcl
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_BRGCG.tcl
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_RBC.tcl
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/create_hbm_RCB.tcl)

add_custom_target(project
   COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_BINARY_DIR}/create_project.tcl
   DEPENDS ${PROJECT_DEPENDS})

add_custom_target(synthesize
   COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_BINARY_DIR}/run_synthesis.tcl
   DEPENDS ${PROJECT_DEPENDS})

add_custom_target(implementation
   COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_BINARY_DIR}/run_implementation.tcl
   DEPENDS ${PROJECT_DEPENDS})

add_custom_target(bitstream
   COMMAND ${VIVADO_BINARY} -mode batch -source ${CMAKE_BINARY_DIR}/generate_bitstream.tcl
   DEPENDS ${PROJECT_DEPENDS})