/*
 * Copyright (c) 2018, Systems Group, ETH Zurich
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef FPGA_CONTROLLER_HPP
#define FPGA_CONTROLLER_HPP

#include <stdio.h>
#include <unistd.h>
#include <byteswap.h>
#include <errno.h>
#include <iostream>
#include <fcntl.h>
#include <inttypes.h>
#include <cstdint>
#include <string>
#include <mutex>
#include <atomic>

#include <sys/types.h>
#include <sys/mman.h>
#include <immintrin.h>                   // include used to acces the intrinsics instructions


#define MAP_SIZE (32*1024UL)

/* ltoh: little to host */
/* htol: little to host */
#if __BYTE_ORDER == __LITTLE_ENDIAN
#  define ltohl(x)       (x)
#  define ltohs(x)       (x)
#  define htoll(x)       (x)
#  define htols(x)       (x)
#elif __BYTE_ORDER == __BIG_ENDIAN
#  define ltohl(x)     __bswap_32(x)
#  define ltohs(x)     __bswap_16(x)
#  define htoll(x)     __bswap_32(x)
#  define htols(x)     __bswap_16(x)
#endif

namespace fpga {
                                     
// one PCie BAR - AXIlite bar is split into 4 kB regions; each interface has one associated region
static const uint64_t userRegAddressOffset = 0;                                // role- user 4 kB  
static const uint64_t dmaRegAddressOffset = 4096;       
static const uint64_t ddrRegAddressOffset[] = { 8192, 12288, 16384, 20480 };   // 4 DDR memories can be connected to the FPGA
static const uint64_t netRegAddressOffset[] = {16384};                         // network stack region 

static const uint64_t mmRegAddressOffset = 0;                                  // bypass space

static const uint32_t cmdFifoDepth = 512;

union VAL{
   struct {
          uint8_t  op;
          uint32_t qpn;          
          uint64_t originAddr;
          uint64_t targetAddr;
          uint32_t size;  
   };
   __m256i x;
};   

class FpgaController
{
   public:
      FpgaController(int fd, int byfd);
      ~FpgaController();
      /*static fpgaManger& getInstance()
      {
         static fpgaManger instance;
         return instance;
      }*/

      void configHBM(uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr, uint32_t hbmChannel);
      void runHBMtest(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel,
                        uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr);
      void readHBMData(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel,uint64_t numOps,uint32_t* memBurstSize);

      void configDDR(uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr, uint32_t hbmChannel);
      void runDDRtest(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel,
                        uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr);
      void readDDRData(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel,uint64_t numOps,uint32_t* memBurstSize);


     private:


      void writeReg(uint32_t addr, uint32_t value);

      uint32_t readReg(uint32_t addr);


   public:
      FpgaController(FpgaController const&)     = delete;
      void operator =(FpgaController const&) = delete;
   private:
   void*  m_base;
   void*  by_base;

   static std::atomic_uint cmdCounter;  //std::atomic<unsigned int>
   //static uint32_t cmdCounter;
   static std::mutex  ctrl_mutex;
   static std::mutex  btree_mutex;

   static uint64_t mmTestValue;
};

} /* namespace fpga */

#endif
