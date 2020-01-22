#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <boost/program_options.hpp>

#include "fpga/Fpga.h"
#include "fpga/FpgaController.h"
#include <fstream>
#include <iomanip>
#include <bitset>


using namespace std;
int main(int argc, char *argv[]) {

   boost::program_options::options_description programDescription("Allowed options");
   programDescription.add_options()("workGroupSize,m", boost::program_options::value<unsigned long>(), "Size of the memory region")
                                    ("readEnable,m",boost::program_options::value<unsigned long>(),"enable signal")
                                    ("channel,m",boost::program_options::value<unsigned long>(),"channel")
                                    //("numOps,o", boost::program_options::value<unsigned int>(), "Number of memory operate")
                                    ("strideLength,s", boost::program_options::value<unsigned int>(), "Stride length between memory accesses")
                                    ("memBurstSize,b", boost::program_options::value<unsigned int>(), "Memory burst size")
                                    //("initialAddr,a", boost::program_options::value<unsigned int>(), "initial address for each channel")
                                    //("hbmChannel,d", boost::program_options::value<unsigned int>(), "hbm channel, all channel:32,default: 0,")
                                    //("WriteOrRead,w", boost::program_options::value<unsigned int>(), "write:1, read:2,write&read:3")
                                    //("Reset,r", boost::program_options::value<unsigned int>(), "reset:1")
                                    ;

   boost::program_options::variables_map commandLineArgs;
   boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
   boost::program_options::notify(commandLineArgs);
   
   fpga::Fpga::setNodeId(0);
   fpga::Fpga::initializeMemory();

   fpga::FpgaController* controller = fpga::Fpga::getController();

   uint32_t workGroupSize[32] = {0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,//0,1,2,...,7
                                 0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,
                                 0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,
                                 0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000,0x10000000};
   uint64_t numOps[32]        = {100000,100000,100000,100000,10000000,10000000,100000,1000000,
                                 1000000,1000000,100000,100000,1000000,1000000,100000,100000,
                                 100000,100000,100000,100000,100000,100000,100000,100000,
                                 100000,100000,100000,100000,100000,100000,100000,100000};
   uint32_t strideLength[32]  = {128,64*2,64*4,64*8,64*16,64*32,64*64,64*128,
                                 64*256,64*512,64*1024,64*2048,64*4096,64,64,64,
                                 64,64,64,64,64,64,64,64,
                                 64,64,64,64,64,64,64,64};
   uint32_t memBurstSize[32]  = {32,128,128,128,128,128,128,128,
                                 128,128,128,128,128,64,64,64,
                                 64,64,64,64,64,64,64,64,
                                 64,64,64,64,64,64,64,64};

   uint32_t initialAddr[32]  =  {0x00000000,0x04000000,0x08000000,0x0c000000,0x10000000,0x14000000,0x18000000,0x1c000000,
                                 0x20000000,0x24000000,0x28000000,0x2c000000,0x30000000,0x34000000,0x38000000,0x3c000000,
                                 0x40000000,0x44000000,0x48000000,0x4c000000,0x50000000,0x54000000,0x58000000,0x5c000000,
                                 0x60000000,0x64000000,0x68000000,0x6c000000,0x70000000,0x74000000,0x78000000,0x7c000000}; //0x7c000000
   for(int i=0;i<32;i++){
      initialAddr[i] = 0x00000000;
      //memBurstSize[i] = 64;
      //strideLength[i] = 0;
   }
   uint32_t hbmChannel    = 0;
   //uint32_t WriteOrRead   = 1;
   //uint32_t Reset         = 0;
   
   //the first channel corresponds to the least significant bit. 
   uint32_t write_enable        = 0x0; //0xFFFFFFFF;
   uint32_t read_enable         = 0x0000; //0x80000000 
   uint32_t latency_test_enable = 0;
   uint32_t latency_channel     = 0;
   //cout<<bitset<sizeof(int)*8>(read_enable)<<endl;
   if(commandLineArgs.count("readEnable") > 0){
      write_enable = commandLineArgs["readEnable"].as<unsigned long>();
      cout<<bitset<sizeof(int)*8>(write_enable)<<endl;
   }
   if(commandLineArgs.count("channel") > 0){
      latency_channel = commandLineArgs["channel"].as<unsigned long>();
      cout<<latency_channel<<endl;
   }
   if (commandLineArgs.count("workGroupSize") > 0) {
         for(int i=0;i<32;i++){
            workGroupSize[i] = commandLineArgs["workGroupSize"].as<unsigned long>();
         }
         cout<<commandLineArgs["workGroupSize"].as<unsigned long>();
   }
   // if (commandLineArgs.count("numOps") > 0) {
   //    numOps = commandLineArgs["numOps"].as<unsigned int>();
   // }
   if (commandLineArgs.count("strideLength") > 0) {
      cout<<commandLineArgs["strideLength"].as<unsigned int>()<<endl;
      for(int i=0;i<32;i++){
         strideLength[i] = commandLineArgs["strideLength"].as<unsigned int>();
      }
   }
   if (commandLineArgs.count("memBurstSize") > 0) {
      for(int i=0;i<=32;i++){
         memBurstSize[i] = commandLineArgs["memBurstSize"].as<unsigned int>();
      }
         cout<<commandLineArgs["memBurstSize"].as<unsigned int>();
      //memBurstSize = commandLineArgs["memBurstSize"].as<unsigned int>();
   }
   // std::ofstream file1;
   // file1.open("../src/test/latency_default_b32_w0x10000000_local.txt",ios::app);
   // file1<<latency_channel<<":"<<endl;

   // if (commandLineArgs.count("hbmChannel") > 0) {
   //    hbmChannel = commandLineArgs["hbmChannel"].as<unsigned int>();
   // }
   // if (commandLineArgs.count("WriteOrRead") > 0) {
   //    WriteOrRead = commandLineArgs["WriteOrRead"].as<unsigned int>();
   // }
   // initialAddr = hbmChannel*0x4000000;  //hbmaddr[33:2]
   // if (commandLineArgs.count("initialAddr") > 0) {
   //     initialAddr = commandLineArgs["initialAddr"].as<unsigned int>();
   // }
   // if (commandLineArgs.count("Reset") > 0) {
   //     Reset = commandLineArgs["Reset"].as<unsigned int>();
   // }
   // std::cout << "workGroupSize:" << workGroupSize << std::endl;
   // std::cout << "numOps:" << numOps << std::endl;
   // std::cout << "strideLength:" << strideLength << std::endl;
   // std::cout << "memBurstSize:" << memBurstSize << std::endl;
   // std::cout << "hbmChannel:" << hbmChannel << std::endl;
   // std::cout << "initialAddr:" << initialAddr << std::endl;
    
   // if(WriteOrRead == 1){
   //    std::cout << "write" << std::endl;
   // }
   // else if(WriteOrRead == 2){
   //    std::cout << "read" << std::endl;
   // }
   // else{
   //    std::cout << "write & read" << std::endl;
   // }

   //void* baseAddr = fpga::Fpga::allocate(memorySize);



   uint64_t cycles = 0;

   for(int i=0;i<32;i++){
      controller->configHBM(workGroupSize[i],numOps[i],strideLength[i],memBurstSize[i],initialAddr[i],i);
   }

   controller->runHBMtest(write_enable, read_enable, latency_test_enable, latency_channel,
                     workGroupSize[latency_channel],numOps[latency_channel],strideLength[latency_channel],memBurstSize[latency_channel],initialAddr[latency_channel]);

   controller->readHBMData(write_enable,read_enable,latency_test_enable, latency_channel,numOps[latency_channel],memBurstSize);

   //cycles = controller->testHBM(workGroupSize,  numOps,  strideLength,  memBurstSize,  initialAddr,  hbmChannel, WriteOrRead, Reset);

   
   
   

   /*std::cout << "Execution cycles: " << cycles << std::endl;
   uint64_t transferSize = ((uint64_t) accesses) * ((uint64_t) chunkLength);
   double transferSizeGB  = ((double) transferSize) / 1024.0 / 1024.0 / 1024.0;
   double tp  =  transferSizeGB / ((double) (clockPeriod*cycles) / 1000.0 / 1000.0 / 1000.0);
   std::cout << std::fixed << "Transfer size [GiB]: " << transferSizeGB << std::endl;
   std::cout << std::fixed << "Throughput[GiB/s]: " << tp << std::endl;
   std::cout << std::fixed << "#" << memorySize << "\t" << transferSizeGB << "\t" << chunkLength << "\t" << strideLength << "\t" << cycles << "\t" << tp << std::endl;

	fpga::Fpga::getController()->printDebugRegs();
   fpga::Fpga::getController()->printDmaStatsRegs();
   fpga::Fpga::getController()->printDdrStatsRegs(0);
   fpga::Fpga::getController()->printDdrStatsRegs(1);*/

   //fpga::Fpga::free(baseAddr);
   fpga::Fpga::clear();

	return 0;

}
