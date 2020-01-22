#include "FpgaController.h"

#include <cstring>
#include <thread>
#include <chrono>
              
#include <fstream>
#include <iomanip>
//#define PRINT_DEBUG

using namespace std::chrono_literals;
using namespace std;

namespace fpga {

std::mutex FpgaController::ctrl_mutex;
std::mutex FpgaController::btree_mutex;
std::atomic_uint FpgaController::cmdCounter = ATOMIC_VAR_INIT(0);
uint64_t FpgaController::mmTestValue;

FpgaController::FpgaController(int fd, int byfd)
{
   //open control device
   m_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
   //open bypass device
   by_base =  mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, byfd, 0);
}

FpgaController::~FpgaController()
{
   if (munmap(m_base, MAP_SIZE) == -1)
   {
      std::cerr << "Error on unmap of control device" << std::endl;
   }

   if (munmap(by_base, MAP_SIZE) == -1)
   {
      std::cerr << "Error on unmap of bypass device" << std::endl;
   }
}







void FpgaController::configHBM(uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr, uint32_t hbmChannel){
   std::lock_guard<std::mutex> guard(ctrl_mutex);
   uint32_t resetAddr = 0;
   uint32_t workGroupSizeAddr = 1;
   uint32_t strideLengthAddr = 2;
   uint32_t numOpsAddrLower = 3;
   uint32_t numOpsAddrUpper = 4;
   uint32_t memBurstSizeAddr = 5;
   uint32_t initialAddrAddr = 6;
   uint32_t latencyTestEnableAddr = 9;
   uint32_t hbmChannelAddr = 10;

   writeReg(hbmChannelAddr, (uint32_t) hbmChannel);
   writeReg(workGroupSizeAddr, (uint32_t) workGroupSize);               
   writeReg(strideLengthAddr, (uint32_t) strideLength);
   writeReg(numOpsAddrLower, (uint32_t) numOps);
   writeReg(numOpsAddrUpper, (uint32_t) (numOps >> 32));
   writeReg(memBurstSizeAddr, (uint32_t) memBurstSize);
   writeReg(initialAddrAddr, (uint32_t) initialAddr);  
   writeReg(latencyTestEnableAddr, (uint32_t) 0);   
}
void FpgaController::runHBMtest(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel, 
                                 uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr){
   std::lock_guard<std::mutex> guard(ctrl_mutex);
   uint32_t resetAddr = 0;
   uint32_t workGroupSizeAddr = 1;
   uint32_t strideLengthAddr = 2;
   uint32_t numOpsAddrLower = 3;
   uint32_t numOpsAddrUpper = 4;
   uint32_t memBurstSizeAddr = 5;
   uint32_t initialAddrAddr = 6;
   uint32_t writeEnableAddr = 7;
   uint32_t readEnableAddr = 8;
   uint32_t latencyTestEnableAddr = 9;
   uint32_t startAddr = 11;
   uint32_t hbmChannelAddr = 10;

   writeReg(hbmChannelAddr, (uint32_t) hbmChannel);
   writeReg(workGroupSizeAddr, (uint32_t) workGroupSize);               
   writeReg(strideLengthAddr, (uint32_t) strideLength);
   writeReg(numOpsAddrLower, (uint32_t) numOps);
   writeReg(numOpsAddrUpper, (uint32_t) (numOps >> 32));
   writeReg(memBurstSizeAddr, (uint32_t) memBurstSize);
   writeReg(initialAddrAddr, (uint32_t) initialAddr);

   writeReg(writeEnableAddr, (uint32_t) write_enable);               
   writeReg(readEnableAddr, (uint32_t) read_enable);
   writeReg(latencyTestEnableAddr, (uint32_t) latency_test_enable);
   writeReg(startAddr, (uint32_t) 1);
   writeReg(startAddr, (uint32_t) 0); 
}

void FpgaController::readHBMData(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel, uint64_t numOps,uint32_t* memBurstSize){
   std::lock_guard<std::mutex> guard(ctrl_mutex);
   uint32_t writeEnableAddr = 7;
   uint32_t readEnableAddr = 8;
   uint32_t latencyTestEnableAddr = 9;
   uint32_t startAddr = 11;
   uint32_t hbmChannelAddr = 10;
   uint32_t endWrAddr = 12;
   uint32_t endRdAddr = 13;
   uint32_t latTimerSumWrAddr = 14;
   uint32_t latTimerSumRdAddr = 15;
   uint32_t latTimerAddr = 16;

   uint64_t endWr;
   uint64_t endRd;
   uint64_t latTimerSumWr = 0;
   uint64_t latTimerSumRd = 0;
   uint64_t latTimer =0;
   float speed;
   uint32_t lat_time_arry[10000];
   writeReg(hbmChannelAddr, (uint32_t) hbmChannel);
   do{
      std::this_thread::sleep_for(1s);
      endWr = readReg(endWrAddr);
      std::cout << "endWr status: " << std::hex << "0x" << endWr << "。" << std::endl; 
      endRd = readReg(endRdAddr);
      std::cout << "endRd status: " << std::hex << "0x" << endRd << "。" << std::endl;
   }while((endWr != write_enable) || (endRd != read_enable));

   std::ofstream file1;
   file1.open("../src/test/crowd_hbm.txt",ios::app);
   for(int i=0;i<=31;i++){
      if((write_enable>>i)&0x01){
         writeReg(hbmChannelAddr, (uint32_t) i);
         latTimerSumWr = readReg(latTimerSumWrAddr);
         speed = memBurstSize[i] * numOps * 450.0 / latTimerSumWr / 1000.0 ;
         std::cout <<  std::dec << "The chennel " << i << ", wr_speed: " << speed << " GB/s" << std::endl;
         file1<<speed<<endl;  
      }
      if((read_enable>>i)&0x01){
         writeReg(hbmChannelAddr, (uint32_t) i);
         latTimerSumRd = readReg(latTimerSumRdAddr);
         speed = memBurstSize[i] * numOps * 450.0 / latTimerSumRd / 1000.0 ;
         std::cout <<  std::dec << "The chennel " << i << ", rd_speed: " << speed << " GB/s" << std::endl;   
         file1<<speed<<endl;  
      }
   }
   file1.close();

   if(latency_test_enable){
      std::ofstream file;
      file.open("../src/test/crossbar.txt",ios::app);
      int sum=0;
      uint64_t numRegReadNum = numOps < 10000? numOps:10000;

      for(uint64_t i =0;i<numRegReadNum;i++){ //numOps
         latTimer = readReg(latTimerAddr);
         lat_time_arry[i] = latTimer;
         //std::cout << "latTimer" << latTimer << "clock" << std::endl;
      }
      for(int i =0;i<100;i++){
         //std::cout << "latTimer" << lat_time_arry[i] << "clock" << std::endl;
         file<<lat_time_arry[i]<<endl;
         sum+=lat_time_arry[i];
         std::cout << "  " << lat_time_arry[i];
         if ( (i>0)&&(i%16==15) )
            std::cout << std::endl; 
      }
      std::cout << std::endl;  
      //file<<sum<<endl;  
      file<<endl; 
      file.close();
   }


}

void FpgaController::configDDR(uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr, uint32_t hbmChannel){
   std::lock_guard<std::mutex> guard(ctrl_mutex);
   uint32_t resetAddr = 0;
   uint32_t workGroupSizeAddr = 1;
   uint32_t strideLengthAddr = 2;
   uint32_t numOpsAddrLower = 3;
   uint32_t numOpsAddrUpper = 4;
   uint32_t memBurstSizeAddr = 5;
   uint32_t initialAddrAddr = 6;
   uint32_t latencyTestEnableAddr = 9;
   uint32_t hbmChannelAddr = 10;

   writeReg(hbmChannelAddr, (uint32_t) hbmChannel);
   writeReg(workGroupSizeAddr, (uint32_t) workGroupSize);               
   writeReg(strideLengthAddr, (uint32_t) strideLength);
   writeReg(numOpsAddrLower, (uint32_t) numOps);
   writeReg(numOpsAddrUpper, (uint32_t) (numOps >> 32));
   writeReg(memBurstSizeAddr, (uint32_t) memBurstSize);
   writeReg(initialAddrAddr, (uint32_t) initialAddr);  
   writeReg(latencyTestEnableAddr, (uint32_t) 0);   
}
void FpgaController::runDDRtest(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel, 
                                 uint32_t workGroupSize, uint64_t numOps, uint32_t strideLength, uint32_t memBurstSize, uint32_t initialAddr){
   std::lock_guard<std::mutex> guard(ctrl_mutex);
   uint32_t resetAddr = 0;
   uint32_t workGroupSizeAddr = 1;
   uint32_t strideLengthAddr = 2;
   uint32_t numOpsAddrLower = 3;
   uint32_t numOpsAddrUpper = 4;
   uint32_t memBurstSizeAddr = 5;
   uint32_t initialAddrAddr = 6;
   uint32_t writeEnableAddr = 7;
   uint32_t readEnableAddr = 8;
   uint32_t latencyTestEnableAddr = 9;
   uint32_t startAddr = 11;
   uint32_t hbmChannelAddr = 10;

   writeReg(hbmChannelAddr, (uint32_t) hbmChannel);
   writeReg(workGroupSizeAddr, (uint32_t) workGroupSize);               
   writeReg(strideLengthAddr, (uint32_t) strideLength);
   writeReg(numOpsAddrLower, (uint32_t) numOps);
   writeReg(numOpsAddrUpper, (uint32_t) (numOps >> 32));
   writeReg(memBurstSizeAddr, (uint32_t) memBurstSize);
   writeReg(initialAddrAddr, (uint32_t) initialAddr);

   writeReg(writeEnableAddr, (uint32_t) write_enable);               
   writeReg(readEnableAddr, (uint32_t) read_enable);
   writeReg(latencyTestEnableAddr, (uint32_t) latency_test_enable);
   writeReg(startAddr, (uint32_t) 1);
   writeReg(startAddr, (uint32_t) 0); 
}

void FpgaController::readDDRData(uint32_t write_enable, uint32_t read_enable, uint32_t latency_test_enable, uint32_t hbmChannel, uint64_t numOps,uint32_t* memBurstSize){
   std::lock_guard<std::mutex> guard(ctrl_mutex);
   uint32_t writeEnableAddr = 7;
   uint32_t readEnableAddr = 8;
   uint32_t latencyTestEnableAddr = 9;
   uint32_t startAddr = 11;
   uint32_t hbmChannelAddr = 10;
   uint32_t endWrAddr = 12;
   uint32_t endRdAddr = 13;
   uint32_t latTimerSumWrAddr = 14;
   uint32_t latTimerSumRdAddr = 15;
   uint32_t latTimerAddr = 16;

   uint64_t endWr;
   uint64_t endRd;
   uint64_t latTimerSumWr = 0;
   uint64_t latTimerSumRd = 0;
   uint64_t latTimer =0;
   float speed;
   uint32_t lat_time_arry[10000];
   writeReg(hbmChannelAddr, (uint32_t) hbmChannel);
   do{
      std::this_thread::sleep_for(1s);
      endWr = readReg(endWrAddr);
      std::cout << "endWr status: " << std::hex << "0x" << endWr << "。" << std::endl; 
      endRd = readReg(endRdAddr);
      std::cout << "endRd status: " << std::hex << "0x" << endRd << "。" << std::endl;
   }while((endWr != write_enable) || (endRd != read_enable));

   std::ofstream file1;
   file1.open("../src/test/crowd_hbm.txt",ios::app);
   for(int i=0;i<=31;i++){
      if((write_enable>>i)&0x01){
         writeReg(hbmChannelAddr, (uint32_t) i);
         latTimerSumWr = readReg(latTimerSumWrAddr);
         speed = memBurstSize[i] * numOps * 300.0 / latTimerSumWr / 1000.0 ;
         std::cout <<  std::dec << "The chennel " << i << ", wr_speed: " << speed << " GB/s" << std::endl;
         file1<<speed<<endl;  
      }
      if((read_enable>>i)&0x01){
         writeReg(hbmChannelAddr, (uint32_t) i);
         latTimerSumRd = readReg(latTimerSumRdAddr);
         speed = memBurstSize[i] * numOps * 300.0 / latTimerSumRd / 1000.0 ;
         std::cout <<  std::dec << "The chennel " << i << ", rd_speed: " << speed << " GB/s" << std::endl;   
         file1<<speed<<endl;  
      }
   }
   file1.close();

   if(latency_test_enable){
      std::ofstream file;
      file.open("../src/test/crossbar.txt",ios::app);
      int sum=0;
      uint64_t numRegReadNum = numOps < 10000? numOps:10000;

      for(uint64_t i =0;i<numRegReadNum;i++){ //numOps
         latTimer = readReg(latTimerAddr);
         lat_time_arry[i] = latTimer;
         //std::cout << "latTimer" << latTimer << "clock" << std::endl;
      }
      for(int i =0;i<100;i++){
         //std::cout << "latTimer" << lat_time_arry[i] << "clock" << std::endl;
         file<<lat_time_arry[i]<<endl;
         sum+=lat_time_arry[i];
         std::cout << "  " << lat_time_arry[i];
         if ( (i>0)&&(i%16==15) )
            std::cout << std::endl; 
      }
      std::cout << std::endl;  
      //file<<sum<<endl;  
      file<<endl; 
      file.close();
   }


}



void FpgaController::writeReg(uint32_t addr, uint32_t value)
{
   volatile uint32_t* wPtr = (uint32_t*) (((uint64_t) m_base) + userRegAddressOffset + (uint64_t) ((uint32_t) addr << 2));
   uint32_t writeVal = htols(value);
   *wPtr = writeVal;
}


/*void FpgaController::writeReg(userCtrlAddr addr, uint64_t value)
{
   uint32_t* wPtr = (uint32_t*) (((uint64_t) m_base) + (uint64_t) ((uint32_t) addr << 5));
   uint32_t writeVal = htols((uint32_t) value);
   *wPtr = writeVal;
   
   writeVal = htols((uint32_t) (value >> 32));
   *wPtr = writeVal;

}*/



uint32_t FpgaController::readReg(uint32_t addr)
{
   volatile uint32_t* rPtr = (uint32_t*) (((uint64_t) m_base) + userRegAddressOffset  + (uint64_t) ((uint32_t) addr << 2));
  return htols(*rPtr);
}







} /* namespace fpga */
