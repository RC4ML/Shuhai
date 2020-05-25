/*
 * Copyright 2019 - 2020, RC4ML, Zhejiang University
 *
 * This hardware operator is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include<string>
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
                                    ("writeEnable,m",boost::program_options::value<unsigned long>(),"enable signal")
                                    ("channel,m",boost::program_options::value<unsigned long>(),"channel")
                                    //("numOps,o", boost::program_options::value<unsigned int>(), "Number of memory operate")
                                    ("strideLength,s", boost::program_options::value<unsigned int>(), "Stride length between memory accesses")
                                    ("memBurstSize,b", boost::program_options::value<unsigned int>(), "Memory burst size")
                                    //("initialAddr,a", boost::program_options::value<unsigned int>(), "initial address for each channel")
                                    //("hbmChannel,d", boost::program_options::value<unsigned int>(), "hbm channel, all channel:32,default: 0,")
                                    //("WriteOrRead,w", boost::program_options::value<unsigned int>(), "write:1, read:2,write&read:3")
                                    //("Reset,r", boost::program_options::value<unsigned int>(), "reset:1")
                                    ("configFile,b", boost::program_options::value<string>(), "configFile")
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
   uint32_t strideLength[32]  = {64,64,64,64,64,64,64,64,
                                 64,64,64,64,64,64,64,64,
                                 64,64,64,64,64,64,64,64,
                                 64,64,64,64,64,64,64,64};
   uint32_t memBurstSize[32]  = {64,64,64,64,64,64,64,64,
                                 64,64,64,64,64,64,64,64,
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
   if(commandLineArgs.count("readEnable") > 0){
      read_enable = commandLineArgs["readEnable"].as<unsigned long>();
      cout<<bitset<sizeof(int)*8>(read_enable)<<endl;
   }
   if(commandLineArgs.count("writeEnable") > 0){
      write_enable = commandLineArgs["writeEnable"].as<unsigned long>();
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
   }

   if (commandLineArgs.count("configFile") > 0) {
      string file = commandLineArgs["configFile"].as<string>();
      string path_config = "../src/"+file;
      ifstream f_config(path_config);
      if(!f_config.is_open()){
         cout<<"open "+file+" failed, check whether it exists."<<endl;
      }else{
         cout<<"open "+file+" succeed."<<endl;
            string s;
            while(getline(f_config,s)){
               if(s=="" || (s[0]=='/'&&s[1]=='/')){
                  continue;
               }
               int index = s.find_first_of(' ');
               string s_cmd = s.substr(0,index);
               string s_data = s.substr(index+1);

               int mchannel = stoi(s_data.substr(0,s_data.find_first_of(" ")) );
               int mvalue = stoi(s_data.substr(s_data.find_first_of(" ")+1));
               //cout<<s_cmd<<" "<<mchannel<<" "<<mvalue<<endl;
               if(s_cmd=="strideLength"){
                  strideLength[mchannel] = mvalue;
               }else if(s_cmd=="workGroupSize"){
                  workGroupSize[mchannel] = mvalue;
               }
               else if(s_cmd=="memBurstSize"){
                  memBurstSize[mchannel] = mvalue;
               }else if(s_cmd=="readEnable"){
                  read_enable = read_enable & (mvalue<<mchannel);
               }else if(s_cmd=="writeEnable"){
                  write_enable = write_enable & (mvalue<<mchannel);
               }else if(s_cmd=="latencyChannel"){
                  latency_channel = mchannel;
                  latency_test_enable = mvalue;
               }
         }
      }
   }


   uint64_t cycles = 0;

   for(int i=0;i<32;i++){
      controller->configHBM(workGroupSize[i],numOps[i],strideLength[i],memBurstSize[i],initialAddr[i],i);
   }

   controller->runHBMtest(write_enable, read_enable, latency_test_enable, latency_channel,
                     workGroupSize[latency_channel],numOps[latency_channel],strideLength[latency_channel],memBurstSize[latency_channel],initialAddr[latency_channel]);

   controller->readHBMData(write_enable,read_enable,latency_test_enable, latency_channel,numOps[latency_channel],memBurstSize);


   fpga::Fpga::clear();

	return 0;

}
