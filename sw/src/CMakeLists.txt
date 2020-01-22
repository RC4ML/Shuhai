# Set up project and cmake
cmake_minimum_required (VERSION 3.1)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/")

project (DmaDriverExample)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

# Set up compilation options
set (CMAKE_CXX_STANDARD 14)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -mavx -march=native ") #-O3 ")

set (CMAKE_C_STANDARD 11)

set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -pthread -mavx -march=native ") #-O3")
set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -pthread -mavx -march=native ") #-O3") 

find_package(Boost COMPONENTS program_options REQUIRED)



# Set up target for main executable

add_executable(test-hbm
    hbm_test.cpp
    fpga/Fpga.cpp
    fpga/FpgaController.cpp
    fpga/MemoryManager.cpp
    )
target_link_libraries(test-hbm
	${Boost_LIBRARIES}
    ) 


add_executable(test-ddr
    ddr_test.cpp
    fpga/Fpga.cpp
    fpga/FpgaController.cpp
    fpga/MemoryManager.cpp
    )
target_link_libraries(test-ddr
	${Boost_LIBRARIES}
    )     





