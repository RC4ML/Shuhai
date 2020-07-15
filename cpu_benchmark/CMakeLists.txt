cmake_minimum_required(VERSION 3.3)
project(throughput)
FIND_PACKAGE(Threads REQUIRED)
add_definitions(-std=c++11)
add_definitions(-mavx)
add_definitions(-march=native)
add_definitions(-pthread)
add_definitions(-mavx512f)

add_definitions(-mavx512f -mavx512cd -mavx512er -mavx512pf -mavx512vl -mavx512dq -mavx512bw)
SET(CMAKE_CXX_COMPILER "/usr/bin/g++")


ADD_EXECUTABLE(throughput throughput.cpp ${DIR_SRCS})
find_package(Threads)
target_link_libraries(throughput ${CMAKE_THREAD_LIBS_INIT})