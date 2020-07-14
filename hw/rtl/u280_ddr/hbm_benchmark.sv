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
////////////////////////////////////////////////////////////////////////////////

`include "hbm_bench.vh"

module hbm_benchmark#(
    parameter N_MEM_INTF    = 2,
    parameter AXI_CHANNELS  = 2,
    parameter PL_LINK_CAP_MAX_LINK_WIDTH          = 16,            // 1- X1; 2 - X2; 4 - X4; 8 - X8
   parameter PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
   parameter PL_LINK_CAP_MAX_LINK_SPEED          = 4,             // 1- GEN1; 2 - GEN2; 4 - GEN3
   parameter C_DATA_WIDTH                        = 512 ,
   parameter EXT_PIPE_SIM                        = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.
   parameter C_ROOT_PORT                         = "FALSE",      // PCIe block is in root port mode
   parameter C_DEVICE_NUMBER                     = 0,            // Device number for Root Port configurations only
   parameter AXIS_CCIX_RX_TDATA_WIDTH     = 256, 
   parameter AXIS_CCIX_TX_TDATA_WIDTH     = 256,
   parameter AXIS_CCIX_RX_TUSER_WIDTH     = 46,
   parameter AXIS_CCIX_TX_TUSER_WIDTH     = 46
)(

    output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txp,
    output [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0] pci_exp_txn,
    input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxp,
    input [(PL_LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  pci_exp_rxn,

//VU9P_TUL_EX_String= FALSE

    input 					 sys_clk_p,
    input 					 sys_clk_n,
    input 					 sys_rst_n,

//input reset,
//    input                       sys_100M_p,
//    input                       sys_100M_n,

/////////ddr0////////
    input                       ddr0_sys_100M_p,
    input                       ddr0_sys_100M_n,
    
    input                       ddr1_sys_100M_p,
    input                       ddr1_sys_100M_n,

    output                      d32_port,

    output                      c0_ddr4_act_n,
    output [16:0]               c0_ddr4_adr,
    output [1:0]                c0_ddr4_ba,
    output [1:0]                c0_ddr4_bg,
    output [0:0]                c0_ddr4_cke,
    output [0:0]                c0_ddr4_odt,
    output [0:0]                c0_ddr4_cs_n,
    output [0:0]                c0_ddr4_ck_t,
    output [0:0]                c0_ddr4_ck_c,
    output                      c0_ddr4_reset_n,
    output                      c0_ddr4_parity,
    inout  [71:0]               c0_ddr4_dq,
    inout  [17:0]               c0_ddr4_dqs_t,
    inout  [17:0]               c0_ddr4_dqs_c,
    
/////////ddr1
    output                      c1_ddr4_act_n,
    output [16:0]               c1_ddr4_adr,
    output [1:0]                c1_ddr4_ba,
    output [1:0]                c1_ddr4_bg,
    output [0:0]                c1_ddr4_cke,
    output [0:0]                c1_ddr4_odt,
    output [0:0]                c1_ddr4_cs_n,
    output [0:0]                c1_ddr4_ck_t,
    output [0:0]                c1_ddr4_ck_c,
    output                      c1_ddr4_reset_n,
    output                      c1_ddr4_parity,
    inout  [71:0]               c1_ddr4_dq,
    inout  [17:0]               c1_ddr4_dqs_t,
    inout  [17:0]               c1_ddr4_dqs_c    
);

    assign d32_port                = 1'b0;
////////////////////////////////////////////////////////////////////////////////
// Localparams
////////////////////////////////////////////////////////////////////////////////
  localparam MMCM_CLKFBOUT_MULT_F  = 18;
  localparam MMCM_CLKOUT0_DIVIDE_F = 2;
  localparam MMCM_DIVCLK_DIVIDE    = 2;
  localparam MMCM_CLKIN1_PERIOD    = 10.000;
  
  localparam MMCM1_CLKFBOUT_MULT_F  = 18;
  localparam MMCM1_CLKOUT0_DIVIDE_F = 2;
  localparam MMCM1_DIVCLK_DIVIDE    = 2;
  localparam MMCM1_CLKIN1_PERIOD    = 10.000;

////////////////////////////////////////////////////////////////////////////////
// Wire Delcaration
////////////////////////////////////////////////////////////////////////////////
   wire               APB_0_PCLK      ;
   wire               APB_0_PRESET_N  ;
   wire               AXI_ACLK_IN_0   ;
   wire               AXI_ARESET_N_0  ;
   wire               HBM_REF_CLK_0   ;
   wire               APB_1_PCLK      ;
   wire               APB_1_PRESET_N  ;
   wire               AXI_ACLK_IN_1   ;
   wire               AXI_ARESET_N_1  ;
   wire               HBM_REF_CLK_1   ;
   wire               DDR0_sys_clk    ;
   wire               DDR1_sys_clk    ;
   wire               ddr_sys_100M    ;
   wire               axi_trans_err   ;
   wire                 locked;
  wire                  ddr0_sys_100M;
  wire                  ddr1_sys_100M;



//  clk_wiz_0 inst_clk_wiz_0
//   (
//    // Clock out ports
//    .clk_out1(APB_0_PCLK),     // output clk_out1
//    .clk_out2(AXI_ACLK_IN_0),     // output clk_out2
//    .clk_out3(HBM_REF_CLK_0),     // output clk_out3
//    .clk_out4(APB_1_PCLK),     // output clk_out4
//    .clk_out5(AXI_ACLK_IN_1),     // output clk_out5
//    .clk_out6(HBM_REF_CLK_1),     // output clk_out6
//    // Status and control signals
//    .reset(1'b0), // input reset
//    .locked(locked),       // output locked
//   // Clock in ports
//    .clk_in1(DDR0_sys_clk));      // input clk_in1
    
//    assign APB_0_PRESET_N = locked;
//    assign AXI_ARESET_N_0 = locked;
//    assign APB_1_PRESET_N = locked;
//    assign AXI_ARESET_N_1 = locked;



/////////////////////////////////////
//(* keep = "TRUE" *)   wire          AXI_ACLK_IN_0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK_IN_1_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK0_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK1_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK2_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK3_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK4_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK5_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK6_st0;
//(* keep = "TRUE" *)   wire          AXI_ACLK0_st0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK1_st0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK2_st0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK3_st0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK4_st0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK5_st0_buf;
//(* keep = "TRUE" *)   wire          AXI_ACLK6_st0_buf;
//(* keep = "TRUE" *)   wire          MMCM_LOCK_0;
//(* keep = "TRUE" *)   wire          MMCM_LOCK_1;

//////////////////////////////////////////////////////////////////////////////////
//// Instantiating BUFG for AXI Clock
//////////////////////////////////////////////////////////////////////////////////
//(* keep = "TRUE" *) wire      APB_0_PCLK_IBUF;
//(* keep = "TRUE" *) wire      APB_0_PCLK_BUF;

//IBUF u_APB_0_PCLK_IBUF  (
//  .I (APB_0_PCLK),
//  .O (APB_0_PCLK_IBUF)
//);

//BUFG u_APB_0_PCLK_BUFG  (
//  .I (APB_0_PCLK_IBUF),
//  .O (APB_0_PCLK_BUF)
//);

//BUFG u_AXI_ACLK_IN_0  (
//  .I (AXI_ACLK_IN_0),
//  .O (AXI_ACLK_IN_0_buf)
//);

//(* keep = "TRUE" *) wire      APB_1_PCLK_IBUF;
//(* keep = "TRUE" *) wire      APB_1_PCLK_BUF;

//IBUF u_APB_1_PCLK_IBUF  (
//  .I (APB_1_PCLK),
//  .O (APB_1_PCLK_IBUF)
//);

//BUFG u_APB_1_PCLK_BUFG  (
//  .I (APB_1_PCLK_IBUF),
//  .O (APB_1_PCLK_BUF)
//);

//BUFG u_AXI_ACLK_IN_1  (
//  .I (AXI_ACLK_IN_1),
//  .O (AXI_ACLK_IN_1_buf)
//);


////////////////////////////////////////////////////
//////////////////reset
////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////
// Instantiating MMCM for AXI clock generation
////////////////////////////////////////////////////////////////////////////////
//MMCME4_ADV
//  #(.BANDWIDTH            ("OPTIMIZED"),
//    .CLKOUT4_CASCADE      ("FALSE"),
//    .COMPENSATION         ("INTERNAL"),
//    .STARTUP_WAIT         ("FALSE"),
//    .DIVCLK_DIVIDE        (MMCM_DIVCLK_DIVIDE),
//    .CLKFBOUT_MULT_F      (MMCM_CLKFBOUT_MULT_F),
//    .CLKFBOUT_PHASE       (0.000),
//    .CLKFBOUT_USE_FINE_PS ("FALSE"),
//    .CLKOUT0_DIVIDE_F     (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKOUT0_PHASE        (0.000),
//    .CLKOUT0_DUTY_CYCLE   (0.500),
//    .CLKOUT0_USE_FINE_PS  ("FALSE"),
//    .CLKOUT1_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKOUT2_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKOUT3_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKOUT4_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKOUT5_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKOUT6_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
//    .CLKIN1_PERIOD        (MMCM_CLKIN1_PERIOD),
//    .REF_JITTER1          (0.010))
//  u_mmcm_0
//    // Output clocks
//   (
//    .CLKFBOUT            (),
//    .CLKFBOUTB           (),
//    .CLKOUT0             (AXI_ACLK0_st0),

//    .CLKOUT0B            (),
//    .CLKOUT1             (AXI_ACLK1_st0),
//    .CLKOUT1B            (),
//    .CLKOUT2             (AXI_ACLK2_st0),
//    .CLKOUT2B            (),
//    .CLKOUT3             (AXI_ACLK3_st0),
//    .CLKOUT3B            (),
//    .CLKOUT4             (AXI_ACLK4_st0),
//    .CLKOUT5             (AXI_ACLK5_st0),
//    .CLKOUT6             (AXI_ACLK6_st0),
//     // Input clock control
//    .CLKFBIN             (), //mmcm_fb
//    .CLKIN1              (AXI_ACLK_IN_0_buf),
//    .CLKIN2              (1'b0),
//    // Other control and status signals
//    .LOCKED              (MMCM_LOCK_0),
//    .PWRDWN              (1'b0),
//    .RST                 (~AXI_ARESET_N_0),
  
//    .CDDCDONE            (),
//    .CLKFBSTOPPED        (),
//    .CLKINSTOPPED        (),
//    .DO                  (),
//    .DRDY                (),
//    .PSDONE              (),
//    .CDDCREQ             (1'b0),
//    .CLKINSEL            (1'b1),
//    .DADDR               (7'b0),
//    .DCLK                (1'b0),
//    .DEN                 (1'b0),
//    .DI                  (16'b0),
//    .DWE                 (1'b0),
//    .PSCLK               (1'b0),
//    .PSEN                (1'b0),
//    .PSINCDEC            (1'b0)
//  );

//BUFG u_AXI_ACLK0_st0  (
//  .I (AXI_ACLK0_st0),
//  .O (AXI_ACLK0_st0_buf)
//);

//BUFG u_AXI_ACLK1_st0  (
//  .I (AXI_ACLK1_st0),
//  .O (AXI_ACLK1_st0_buf)
//);

//BUFG u_AXI_ACLK2_st0  (
//  .I (AXI_ACLK2_st0),
//  .O (AXI_ACLK2_st0_buf)
//);

//BUFG u_AXI_ACLK3_st0  (
//  .I (AXI_ACLK3_st0),
//  .O (AXI_ACLK3_st0_buf)
//);

//BUFG u_AXI_ACLK4_st0  (
//  .I (AXI_ACLK4_st0),
//  .O (AXI_ACLK4_st0_buf)
//);

//BUFG u_AXI_ACLK5_st0  (
//  .I (AXI_ACLK5_st0),
//  .O (AXI_ACLK5_st0_buf)
//);

//BUFG u_AXI_ACLK6_st0  (
//  .I (AXI_ACLK6_st0),
//  .O (AXI_ACLK6_st0_buf)
//);


//MMCME4_ADV
//  #(.BANDWIDTH            ("OPTIMIZED"),
//    .CLKOUT4_CASCADE      ("FALSE"),
//    .COMPENSATION         ("INTERNAL"),
//    .STARTUP_WAIT         ("FALSE"),
//    .DIVCLK_DIVIDE        (MMCM1_DIVCLK_DIVIDE),
//    .CLKFBOUT_MULT_F      (MMCM1_CLKFBOUT_MULT_F),
//    .CLKFBOUT_PHASE       (0.000),
//    .CLKFBOUT_USE_FINE_PS ("FALSE"),
//    .CLKOUT0_DIVIDE_F     (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKOUT0_PHASE        (0.000),
//    .CLKOUT0_DUTY_CYCLE   (0.500),
//    .CLKOUT0_USE_FINE_PS  ("FALSE"),
//    .CLKOUT1_DIVIDE       (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKOUT2_DIVIDE       (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKOUT3_DIVIDE       (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKOUT4_DIVIDE       (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKOUT5_DIVIDE       (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKOUT6_DIVIDE       (MMCM1_CLKOUT0_DIVIDE_F),
//    .CLKIN1_PERIOD        (MMCM1_CLKIN1_PERIOD),
//    .REF_JITTER1          (0.010))
//  u_mmcm_1
//    // Output clocks
//   (
//    .CLKFBOUT            (),
//    .CLKFBOUTB           (),

//    .CLKOUT0             (AXI_ACLK0_st1),

//    .CLKOUT0B            (),
//    .CLKOUT1             (AXI_ACLK1_st1),
//    .CLKOUT1B            (),
//    .CLKOUT2             (AXI_ACLK2_st1),
//    .CLKOUT2B            (),
//    .CLKOUT3             (AXI_ACLK3_st1),
//    .CLKOUT3B            (),
//    .CLKOUT4             (AXI_ACLK4_st1),
//    .CLKOUT5             (AXI_ACLK5_st1),
//    .CLKOUT6             (AXI_ACLK6_st1),
//     // Input clock control
//    .CLKFBIN             (), //mmcm_fb
//    .CLKIN1              (AXI_ACLK_IN_1_buf),
//    .CLKIN2              (1'b0),
//    // Other control and status signals
//    .LOCKED              (MMCM_LOCK_1),
//    .PWRDWN              (1'b0),
//    .RST                 (~AXI_ARESET_N_1),
  
//    .CDDCDONE            (),
//    .CLKFBSTOPPED        (),
//    .CLKINSTOPPED        (),
//    .DO                  (),
//    .DRDY                (),
//    .PSDONE              (),
//    .CDDCREQ             (1'b0),
//    .CLKINSEL            (1'b1),
//    .DADDR               (7'b0),
//    .DCLK                (1'b0),
//    .DEN                 (1'b0),
//    .DI                  (16'b0),
//    .DWE                 (1'b0),
//    .PSCLK               (1'b0),
//    .PSEN                (1'b0),
//    .PSINCDEC            (1'b0)
//  );

//BUFG u_AXI_ACLK0_st1  (
//  .I (AXI_ACLK0_st1),
//  .O (AXI_ACLK0_st1_buf)
//);

//BUFG u_AXI_ACLK1_st1  (
//  .I (AXI_ACLK1_st1),
//  .O (AXI_ACLK1_st1_buf)
//);

//BUFG u_AXI_ACLK2_st1  (
//  .I (AXI_ACLK2_st1),
//  .O (AXI_ACLK2_st1_buf)
//);

//BUFG u_AXI_ACLK3_st1  (
//  .I (AXI_ACLK3_st1),
//  .O (AXI_ACLK3_st1_buf)
//);

//BUFG u_AXI_ACLK4_st1  (
//  .I (AXI_ACLK4_st1),
//  .O (AXI_ACLK4_st1_buf)
//);

//BUFG u_AXI_ACLK5_st1  (
//  .I (AXI_ACLK5_st1),
//  .O (AXI_ACLK5_st1_buf)
//);

//BUFG u_AXI_ACLK6_st1  (
//  .I (AXI_ACLK6_st1),
//  .O (AXI_ACLK6_st1_buf)
//);




AXI #(
    .ADDR_WIDTH    (34 ), 
    .DATA_WIDTH    (512),
    .PARAMS_BITS   (256),
    .ID_WIDTH      (5  ),
    .USER_WIDTH    (5  )
    ) hbm_axi[AXI_CHANNELS]();

//add the benchmarking code here////
    
    wire  [  7:0]                               channel_choice;
    reg  [N_MEM_INTF-1:0]                       start_wr;
    reg  [N_MEM_INTF-1:0]                       start_rd; 
    wire                                        start_wr_i;
    wire                                        start_rd_i;
    // reg  [N_MEM_INTF-1:0]                       start_wr_r,start_wr_rr;
    // reg  [N_MEM_INTF-1:0]                       start_rd_r,start_rd_rr;
    reg  [N_MEM_INTF-1:0]                       start_r,start_rr;
    wire [N_MEM_INTF-1:0]                       end_wr;
    reg  [N_MEM_INTF-1:0]                       end_wr_o;
    wire [N_MEM_INTF-1:0][63:0]                 lat_timer_sum_wr;
    wire [N_MEM_INTF-1:0]                       end_rd          ;
    reg  [N_MEM_INTF-1:0]                       end_rd_o;
    wire [N_MEM_INTF-1:0][63:0]                 lat_timer_sum_rd;      
    wire [N_MEM_INTF-1:0]                       lat_timer_valid ; //log down lat_timer when lat_timer_valid is 1. 
    wire [N_MEM_INTF-1:0][15:0]                 lat_timer       ;
    
    wire [31:0]                                 lat_timer_sum_wr_o;
    wire [31:0]                                 lat_timer_sum_rd_o;      
    reg                                         lat_timer_valid_o ; //log down lat_timer when lat_timer_valid is 1. 
    reg  [15:0]                                 lat_timer_o       ;

    //--------------------Parameters-----------------------------//
    reg  [N_MEM_INTF-1:0]                       ld_params_wr;
    reg  [N_MEM_INTF-1:0]                       ld_params_rd;
    wire                                        ld_params_wr_i;
    wire                                        ld_params_rd_i;  
    wire                                        all_channel_flag;  
    wire                                        all_start;
    reg  [N_MEM_INTF-1:0]                       all_start_r,all_start_rr;
    wire [ 63:0]                                initial_addr;

    reg   [N_MEM_INTF-1:0][511:0]               lt_params;
    wire  [ 31:0]                               work_group_size;
    wire  [ 31:0]                               stride;
    wire  [ 63:0]                               num_mem_ops;
    wire  [ 31:0]                               mem_burst_size;
    wire  [  7:0]                               hbm_channel;
    wire  [  3:0]                               operate;
    wire                                        hbm_reset;
    wire                                        latency_test_enable;
    wire  [N_MEM_INTF-1:0]                      write_enable;
    wire  [N_MEM_INTF-1:0]                      read_enable;
    wire  [N_MEM_INTF-1:0]                      hbm_axi_clk;

    
//vio_0 inst_vio_0 (
//  .clk(hbm_axi[0].clk),                // input wire clk
//  .probe_in0(end_wr_o),    // input wire [0 : 0] probe_in0
//  .probe_in1(end_rd_o),    // input wire [0 : 0] probe_in1
//  .probe_in2(lat_timer_valid_o),    // input wire [0 : 0] probe_in2
//  .probe_in3(lat_timer_sum_wr_o),    // input wire [63 : 0] probe_in3
//  .probe_in4(lat_timer_sum_rd_o),    // input wire [63 : 0] probe_in4
//  .probe_in5(lat_timer_o),    // input wire [15 : 0] probe_in5
//  .probe_out0(start_wr_i),  // output wire [0 : 0] probe_out0
//  .probe_out1(start_rd_i),  // output wire [0 : 0] probe_out1
//  .probe_out2(ld_params_wr_i),  // output wire [0 : 0] probe_out2
//  .probe_out3(ld_params_rd_i),  // output wire [0 : 0] probe_out3
//  .probe_out4(work_group_size),  // output wire [31 : 0] probe_out4
//  .probe_out5(stride),  // output wire [31 : 0] probe_out5
//  .probe_out6(num_mem_ops),  // output wire [63 : 0] probe_out6
//  .probe_out7(mem_burst_size),  // output wire [31 : 0] probe_out7
//  .probe_out8(hbm_channel),  // output wire [7 : 0] probe_out8
//  .probe_out9(all_channel_flag),  // output wire [0 : 0] probe_out9
//  .probe_out10(all_start),  // output wire [0 : 0] probe_out10
//  .probe_out11(initial_addr)  // output wire [31 : 0] probe_out11
//);  
//  assign end_wr_o = end_wr[hbm_channel];
//  assign end_rd_o = end_rd[hbm_channel];
//  assign lat_timer_valid_o = lat_timer_valid[hbm_channel];
//  assign lat_timer_sum_wr_o = lat_timer_sum_wr[hbm_channel];
//  assign lat_timer_sum_rd_o = lat_timer_sum_rd[hbm_channel];
//  assign lat_timer_o = lat_timer[hbm_channel];

  assign lat_timer_sum_wr_o = lat_timer_sum_wr[hbm_channel][31:0];
  assign lat_timer_sum_rd_o = lat_timer_sum_rd[hbm_channel][31:0];

//    always @(posedge hbm_axi[i].clk) begin
//        if(~MMCM_LOCK_0)begin
//            lat_timer_o                 <= 16'b0;
//            lat_timer_valid_o           <= 1'b0;
//        end
//        else begin
//            lat_timer_o                 <= lat_timer[hbm_channel] ;
//            lat_timer_valid_o           <= lat_timer_valid[hbm_channel];
//        end
//    end




//generate end generate
genvar i;
// Instantiate engines
generate
for(i = 0; i < N_MEM_INTF; i++) 
begin

    always @(posedge hbm_axi[i].clk) begin
        if(~hbm_axi[i].arstn)begin
            lt_params[i][ 31:  0]       <=  work_group_size;
            lt_params[i][ 63: 32]       <=  stride;
            lt_params[i][127: 64]       <=  num_mem_ops;
            lt_params[i][159:128]       <=  mem_burst_size;
            lt_params[i][64+159:160]    <=  32'h1000_0000 * i;
            lt_params[i][224]           <=  1'b0;
            lt_params[i][225+:5]        <=  i;
            lt_params[i][511:256]       <=  lt_params[i][255:0];
        end
        else if(hbm_channel == i)begin
            lt_params[i][ 31:  0]       <=  work_group_size;
            lt_params[i][ 63: 32]       <=  stride;
            lt_params[i][127: 64]       <=  num_mem_ops;
            lt_params[i][159:128]       <=  mem_burst_size;
            lt_params[i][64+159:160]    <=  initial_addr;
            lt_params[i][224]           <=  latency_test_enable;
            lt_params[i][225+:5]        <=  i;
            lt_params[i][511:256]       <=  lt_params[i][255:0];
        end
        else begin 
            lt_params[i]                <=  lt_params[i];
        end
    end
    
    always @(posedge hbm_axi[i].clk) begin
        start_r[i]                         <= start;
        start_rr[i]                        <= start_r[i];              
    end
    
    
    always @(posedge hbm_axi[i].clk) begin
        if(~hbm_axi[i].arstn)begin
            start_wr[i]                 <= 1'b0;
            ld_params_wr[i]             <= 1'b1;
        end
        else if(write_enable[i])begin
            start_wr[i]                 <= (start_r[i] & (~start_rr[i])) ;
            ld_params_wr[i]             <= 1'b1;
        end
        else begin
            start_wr[i]                 <= start_wr[i];
        end
    end

    always @(posedge hbm_axi[i].clk) begin
        if(~hbm_axi[i].arstn)begin
            start_rd[i]                 <= 1'b0;
            ld_params_rd[i]             <= 1'b1;
        end
        else if(read_enable[i])begin
            start_rd[i]                 <= (start_r[i] & (~start_rr[i])) ;
            ld_params_rd[i]             <= 1'b1;
        end
        else begin
            start_rd[i]                 <= start_rd[i];
        end
    end


    always @(posedge hbm_axi[i].clk) begin
        if(~hbm_axi[i].arstn)begin
            end_wr_o[i]                 <= 1'b0;
        end
        else if(start_r & (~start_rr))begin
            end_wr_o[i]                 <= 1'b0;
        end
        else if(end_wr[i])begin
            end_wr_o[i]                 <= 1'b1 ;
        end
        else begin
            end_wr_o[i]                 <= end_wr_o[i];
        end
    end


    always @(posedge hbm_axi[i].clk) begin
        if(~hbm_axi[i].arstn)begin
            end_rd_o[i]                 <= 1'b0;
        end
        else if(start_r & (~start_rr))begin
            end_rd_o[i]                 <= 1'b0;
        end
        else if(end_rd[i])begin
            end_rd_o[i]                 <= 1'b1 ;
        end
        else begin
            end_rd_o[i]                 <= end_rd_o[i];
        end
    end
    



    lt_engine #(
        .ENGINE_ID        (i   ),
        .ADDR_WIDTH       (34  ),  // 8G-->33 bits
        .DATA_WIDTH       (512 ),  // 512-bit for DDR4
        .PARAMS_BITS      (256 ),  // parameter bits from PCIe
        .ID_WIDTH         (5   )   //,
    )inst_lt_engine(
    .clk              (hbm_axi[i].clk),   //should be 450MHz, 
    .rst_n            (hbm_axi[i].arstn), //negative reset,   
    //---------------------Begin/Stop-----------------------------//
    .start_wr         (start_wr[i]),
    .end_wr           (end_wr[i]),
    .lat_timer_sum_wr (lat_timer_sum_wr[i]),
    .start_rd         (start_rd[i]),
    .end_rd           (end_rd[i]),
    .lat_timer_sum_rd (lat_timer_sum_rd[i]),
    .lat_timer_valid  (lat_timer_valid[i]),
    .lat_timer        (lat_timer[i]),
    //---------------------Parameters-----------------------------//
    .ld_params_wr       (ld_params_wr[i]),
    .ld_params_rd       (ld_params_rd[i]),
    .lt_params        (lt_params[i]),


    .m_axi_AWADDR     (hbm_axi[i].awaddr  ), //wr byte address
    .m_axi_AWBURST    (hbm_axi[i].awburst ), //wr burst type: 01 (INC), 00 (FIXED)
    .m_axi_AWID       (hbm_axi[i].awid    ), //wr address id
    .m_axi_AWLEN      (hbm_axi[i].awlen   ), //wr burst=awlen+1,
    .m_axi_AWSIZE     (hbm_axi[i].awsize  ), //wr 3'b101, 32B
    .m_axi_AWVALID    (hbm_axi[i].awvalid ), //wr address valid
    .m_axi_AWREADY    (hbm_axi[i].awready ), //wr ready to accept address.
    .m_axi_AWLOCK     (hbm_axi[i].awlock), //wr no
    .m_axi_AWCACHE    (hbm_axi[i].awcache), //wr no
    .m_axi_AWPROT     (hbm_axi[i].awprot), //wr no
    .m_axi_AWQOS      (hbm_axi[i].awqos), //wr no
    .m_axi_AWREGION   (), //wr no

    //Write data (output)  
    .m_axi_WDATA      (hbm_axi[i].wdata  ), //wr data
    .m_axi_WLAST      (hbm_axi[i].wlast  ), //wr last beat in a burst
    .m_axi_WSTRB      (hbm_axi[i].wstrb  ), //wr data strob
    .m_axi_WVALID     (hbm_axi[i].wvalid ), //wr data valid
    .m_axi_WREADY     (hbm_axi[i].wready ), //wr ready to accept data
    .m_axi_WID        (), //wr data id

    //Write response (input)  
    .m_axi_BID        (hbm_axi[i].bid    ),
    .m_axi_BRESP      (hbm_axi[i].bresp  ),
    .m_axi_BVALID     (hbm_axi[i].bvalid ), 
    .m_axi_BREADY     (hbm_axi[i].bready ),

    //Read Address (Output)  
    .m_axi_ARADDR     (hbm_axi[i].araddr  ), //rd byte address
    .m_axi_ARBURST    (hbm_axi[i].arburst ), //rd burst type: 01 (INC), 00 (FIXED)
    .m_axi_ARID       (hbm_axi[i].arid    ), //rd address id
    .m_axi_ARLEN      (hbm_axi[i].arlen   ), //rd burst=awlen+1,
    .m_axi_ARSIZE     (hbm_axi[i].arsize  ), //rd 3'b101, 32B
    .m_axi_ARVALID    (hbm_axi[i].arvalid ), //rd address valid
    .m_axi_ARREADY    (hbm_axi[i].arready ), //rd ready to accept address.
    .m_axi_ARLOCK     (hbm_axi[i].arlock), //rd no
    .m_axi_ARCACHE    (hbm_axi[i].arcache), //rd no
    .m_axi_ARPROT     (hbm_axi[i].arprot), //rd no
    .m_axi_ARQOS      (hbm_axi[i].arqos), //rd no
    .m_axi_ARREGION   (), //rd no

    //Read Data (input)
    .m_axi_RDATA      (hbm_axi[i].rdata  ), //rd data 
    .m_axi_RLAST      (hbm_axi[i].rlast  ), //rd data last
    .m_axi_RID        (hbm_axi[i].rid    ), //rd data id
    .m_axi_RRESP      (hbm_axi[i].rresp  ), //rd data status. 
    .m_axi_RVALID     (hbm_axi[i].rvalid ), //rd data valid
    .m_axi_RREADY     (hbm_axi[i].rready )
);
      assign hbm_axi_clk[i]     = hbm_axi[i].clk;
//    assign hbm_axi[i].clk   = c0_ddr4_clk;    //fixme
    //assign hbm_axi[i].arstn = MMCM_LOCK_0 & (~hbm_reset);//( i < 16) ? MMCM_LOCK_0 : MMCM_LOCK_1; //fixme  
    //assign hbm_axi_clk[i]   = hbm_axi[i].clk;
end
endgenerate

//ila_rd_engine inst_bebug_rd_engine (
//   .clk (AXI_ACLK0_st0_buf),

//   .probe0  (hbm_axi[0].arvalid  ),
//   .probe1  (hbm_axi[0].araddr    ),
//   .probe2  (hbm_axi[0].arlen     ),
//   .probe3  (hbm_axi[0].arsize    ),
//   .probe4  (hbm_axi[0].arready   ),
//   .probe5  (0         ),
//   .probe6  (hbm_axi[0].rvalid    ),
//   .probe7  (hbm_axi[0].rlast     ),
//   .probe8  (0   ),
//   .probe9  (0          ),
//   .probe10 (0 ),
//   .probe11 (0    ),
//   .probe12 (0 ),
//   .probe13 (  0 ),
//   .probe14 (lt_params[0][255:0]     ),
//   .probe15 (0  ),
//   .probe16 (0           ),
//   .probe17 (hbm_axi[0].rresp     )  
//);


    // assign hbm_axi[ 0].clk   = AXI_ACLK0_st0_buf;
    // assign hbm_axi[ 1].clk   = AXI_ACLK0_st0_buf;
    // assign hbm_axi[ 2].clk   = AXI_ACLK1_st0_buf;
    // assign hbm_axi[ 3].clk   = AXI_ACLK1_st0_buf;
    // assign hbm_axi[ 4].clk   = AXI_ACLK2_st0_buf;
    // assign hbm_axi[ 5].clk   = AXI_ACLK2_st0_buf;
    // assign hbm_axi[ 6].clk   = AXI_ACLK3_st0_buf;
    // assign hbm_axi[ 7].clk   = AXI_ACLK3_st0_buf;
    // assign hbm_axi[ 8].clk   = AXI_ACLK4_st0_buf;
    // assign hbm_axi[ 9].clk   = AXI_ACLK4_st0_buf;
    // assign hbm_axi[10].clk   = AXI_ACLK5_st0_buf;
    // assign hbm_axi[11].clk   = AXI_ACLK5_st0_buf;
    // assign hbm_axi[12].clk   = AXI_ACLK5_st0_buf;
    // assign hbm_axi[13].clk   = AXI_ACLK6_st0_buf;
    // assign hbm_axi[14].clk   = AXI_ACLK6_st0_buf;
    // assign hbm_axi[15].clk   = AXI_ACLK6_st0_buf;
    // assign hbm_axi[16].clk   = AXI_ACLK0_st0_buf;
    // assign hbm_axi[17].clk   = AXI_ACLK0_st0_buf;
    // assign hbm_axi[18].clk   = AXI_ACLK1_st0_buf;
    // assign hbm_axi[19].clk   = AXI_ACLK1_st0_buf;
    // assign hbm_axi[20].clk   = AXI_ACLK2_st0_buf;
    // assign hbm_axi[21].clk   = AXI_ACLK2_st0_buf;
    // assign hbm_axi[22].clk   = AXI_ACLK3_st0_buf;
    // assign hbm_axi[23].clk   = AXI_ACLK3_st0_buf;
    // assign hbm_axi[24].clk   = AXI_ACLK4_st0_buf;
    // assign hbm_axi[25].clk   = AXI_ACLK4_st0_buf;
    // assign hbm_axi[26].clk   = AXI_ACLK5_st0_buf;
    // assign hbm_axi[27].clk   = AXI_ACLK5_st0_buf;
    // assign hbm_axi[28].clk   = AXI_ACLK5_st0_buf;
    // assign hbm_axi[29].clk   = AXI_ACLK6_st0_buf;
    // assign hbm_axi[30].clk   = AXI_ACLK6_st0_buf;
    // assign hbm_axi[31].clk   = AXI_ACLK6_st0_buf;

//
//hbm_0 inst_hbm (
//    .HBM_REF_CLK_0       (HBM_REF_CLK_0      ),
//    .HBM_REF_CLK_1       (HBM_REF_CLK_1      ),

//    .AXI_00_ACLK         (hbm_axi[0].clk    ), //clk
//    .AXI_00_ARESET_N     (hbm_axi[0].arstn  ), //resetn
//    .AXI_00_ARADDR       (hbm_axi[0].araddr ), //read address
//    .AXI_00_ARBURST      (hbm_axi[0].arburst), //read burst type: 01
//    .AXI_00_ARID         (hbm_axi[0].arid   ), //read id
//    .AXI_00_ARLEN        (hbm_axi[0].arlen  ), //read burst size
//    .AXI_00_ARSIZE       (hbm_axi[0].arsize ), //3'b101: 256-bit, 
//    .AXI_00_ARVALID      (hbm_axi[0].arvalid), //read address valid
//    .AXI_00_ARREADY      (hbm_axi[0].arready), //read address ready///////////
//    .AXI_00_RDATA        (hbm_axi[0].rdata  ), //read data
//    .AXI_00_RID          (hbm_axi[0].rid    ), //read data id
//    .AXI_00_RLAST        (hbm_axi[0].rlast  ), //read data last
//    .AXI_00_RRESP        (hbm_axi[0].rresp  ), //read data status
//    .AXI_00_RVALID       (hbm_axi[0].rvalid ), //read data valid
//    .AXI_00_RREADY       (hbm_axi[0].rready ), //read data ready
//    .AXI_00_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_00_AWADDR       (hbm_axi[0].awaddr ), //write address
//    .AXI_00_AWBURST      (hbm_axi[0].awburst), //write burst type
//    .AXI_00_AWID         (hbm_axi[0].awid   ), //write id
//    .AXI_00_AWLEN        (hbm_axi[0].awlen  ), //write burst size
//    .AXI_00_AWSIZE       (hbm_axi[0].awsize ), //write transaction size
//    .AXI_00_AWVALID      (hbm_axi[0].awvalid), //write address valid
//    .AXI_00_AWREADY      (hbm_axi[0].awready), //write address ready//////////
//    .AXI_00_WDATA        (hbm_axi[0].wdata  ), //write data
//    .AXI_00_WLAST        (hbm_axi[0].wlast  ), //write data last
//    .AXI_00_WSTRB        (hbm_axi[0].wstrb  ), //write data strobe
//    .AXI_00_WVALID       (hbm_axi[0].wvalid ), //write valid
//    .AXI_00_WREADY       (hbm_axi[0].wready ), //write data ready
//    .AXI_00_WDATA_PARITY (  0               ), //////////////////////////////
//    .AXI_00_BID          (hbm_axi[0].bid    ), //write response id
//    .AXI_00_BRESP        (hbm_axi[0].bresp  ), //write response
//    .AXI_00_BVALID       (hbm_axi[0].bvalid ), //write response valid
//    .AXI_00_BREADY       (hbm_axi[0].bready ), //write response ready

//    .AXI_01_ACLK         (hbm_axi[1].clk    ), //clk
//    .AXI_01_ARESET_N     (hbm_axi[1].arstn  ), //resetn
//    .AXI_01_ARADDR       (hbm_axi[1].araddr ), //read address
//    .AXI_01_ARBURST      (hbm_axi[1].arburst), //read burst type: 01
//    .AXI_01_ARID         (hbm_axi[1].arid   ), //read id
//    .AXI_01_ARLEN        (hbm_axi[1].arlen  ), //read burst size
//    .AXI_01_ARSIZE       (hbm_axi[1].arsize ), //3'b101: 256-bit, 
//    .AXI_01_ARVALID      (hbm_axi[1].arvalid), //read address valid
//    .AXI_01_ARREADY      (hbm_axi[1].arready), //read address ready///////////
//    .AXI_01_RDATA        (hbm_axi[1].rdata  ), //read data
//    .AXI_01_RID          (hbm_axi[1].rid    ), //read data id
//    .AXI_01_RLAST        (hbm_axi[1].rlast  ), //read data last
//    .AXI_01_RRESP        (hbm_axi[1].rresp  ), //read data status
//    .AXI_01_RVALID       (hbm_axi[1].rvalid ), //read data valid
//    .AXI_01_RREADY       (hbm_axi[1].rready ), //read data ready
//    .AXI_01_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_01_AWADDR       (hbm_axi[1].awaddr ), //write address
//    .AXI_01_AWBURST      (hbm_axi[1].awburst), //write burst type
//    .AXI_01_AWID         (hbm_axi[1].awid   ), //write id
//    .AXI_01_AWLEN        (hbm_axi[1].awlen  ), //write burst size
//    .AXI_01_AWSIZE       (hbm_axi[1].awsize ), //write transaction size
//    .AXI_01_AWVALID      (hbm_axi[1].awvalid), //write address valid
//    .AXI_01_AWREADY      (hbm_axi[1].awready), //write address ready//////////
//    .AXI_01_WDATA        (hbm_axi[1].wdata  ), //write data
//    .AXI_01_WLAST        (hbm_axi[1].wlast  ), //write data last
//    .AXI_01_WSTRB        (hbm_axi[1].wstrb  ), //write data strobe
//    .AXI_01_WVALID       (hbm_axi[1].wvalid ), //write valid
//    .AXI_01_WREADY       (hbm_axi[1].wready ), //write data ready
//    .AXI_01_WDATA_PARITY (    0             ), //////////////////////////////
//    .AXI_01_BID          (hbm_axi[1].bid    ), //write response id
//    .AXI_01_BRESP        (hbm_axi[1].bresp  ), //write response
//    .AXI_01_BVALID       (hbm_axi[1].bvalid ), //write response valid
//    .AXI_01_BREADY       (hbm_axi[1].bready ), //write response ready

//    .AXI_02_ACLK         (hbm_axi[2].clk    ), //clk
//    .AXI_02_ARESET_N     (hbm_axi[2].arstn  ), //resetn
//    .AXI_02_ARADDR       (hbm_axi[2].araddr ), //read address
//    .AXI_02_ARBURST      (hbm_axi[2].arburst), //read burst type: 01
//    .AXI_02_ARID         (hbm_axi[2].arid   ), //read id
//    .AXI_02_ARLEN        (hbm_axi[2].arlen  ), //read burst size
//    .AXI_02_ARSIZE       (hbm_axi[2].arsize ), //3'b101: 256-bit, 
//    .AXI_02_ARVALID      (hbm_axi[2].arvalid), //read address valid
//    .AXI_02_ARREADY      (hbm_axi[2].arready), //read address ready///////////
//    .AXI_02_RDATA        (hbm_axi[2].rdata  ), //read data
//    .AXI_02_RID          (hbm_axi[2].rid    ), //read data id
//    .AXI_02_RLAST        (hbm_axi[2].rlast  ), //read data last
//    .AXI_02_RRESP        (hbm_axi[2].rresp  ), //read data status
//    .AXI_02_RVALID       (hbm_axi[2].rvalid ), //read data valid
//    .AXI_02_RREADY       (hbm_axi[2].rready ), //read data ready
//    .AXI_02_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_02_AWADDR       (hbm_axi[2].awaddr ), //write address
//    .AXI_02_AWBURST      (hbm_axi[2].awburst), //write burst type
//    .AXI_02_AWID         (hbm_axi[2].awid   ), //write id
//    .AXI_02_AWLEN        (hbm_axi[2].awlen  ), //write burst size
//    .AXI_02_AWSIZE       (hbm_axi[2].awsize ), //write transaction size
//    .AXI_02_AWVALID      (hbm_axi[2].awvalid), //write address valid
//    .AXI_02_AWREADY      (hbm_axi[2].awready), //write address ready//////////
//    .AXI_02_WDATA        (hbm_axi[2].wdata  ), //write data
//    .AXI_02_WLAST        (hbm_axi[2].wlast  ), //write data last
//    .AXI_02_WSTRB        (hbm_axi[2].wstrb  ), //write data strobe
//    .AXI_02_WVALID       (hbm_axi[2].wvalid ), //write valid
//    .AXI_02_WREADY       (hbm_axi[2].wready ), //write data ready
//    .AXI_02_WDATA_PARITY (   0              ), //////////////////////////////
//    .AXI_02_BID          (hbm_axi[2].bid    ), //write response id
//    .AXI_02_BRESP        (hbm_axi[2].bresp  ), //write response
//    .AXI_02_BVALID       (hbm_axi[2].bvalid ), //write response valid
//    .AXI_02_BREADY       (hbm_axi[2].bready ), //write response ready

//    .AXI_03_ACLK         (hbm_axi[3].clk    ), //clk
//    .AXI_03_ARESET_N     (hbm_axi[3].arstn  ), //resetn
//    .AXI_03_ARADDR       (hbm_axi[3].araddr ), //read address
//    .AXI_03_ARBURST      (hbm_axi[3].arburst), //read burst type: 01
//    .AXI_03_ARID         (hbm_axi[3].arid   ), //read id
//    .AXI_03_ARLEN        (hbm_axi[3].arlen  ), //read burst size
//    .AXI_03_ARSIZE       (hbm_axi[3].arsize ), //3'b101: 256-bit, 
//    .AXI_03_ARVALID      (hbm_axi[3].arvalid), //read address valid
//    .AXI_03_ARREADY      (hbm_axi[3].arready), //read address ready///////////
//    .AXI_03_RDATA        (hbm_axi[3].rdata  ), //read data
//    .AXI_03_RID          (hbm_axi[3].rid    ), //read data id
//    .AXI_03_RLAST        (hbm_axi[3].rlast  ), //read data last
//    .AXI_03_RRESP        (hbm_axi[3].rresp  ), //read data status
//    .AXI_03_RVALID       (hbm_axi[3].rvalid ), //read data valid
//    .AXI_03_RREADY       (hbm_axi[3].rready ), //read data ready
//    .AXI_03_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_03_AWADDR       (hbm_axi[3].awaddr ), //write address
//    .AXI_03_AWBURST      (hbm_axi[3].awburst), //write burst type
//    .AXI_03_AWID         (hbm_axi[3].awid   ), //write id
//    .AXI_03_AWLEN        (hbm_axi[3].awlen  ), //write burst size
//    .AXI_03_AWSIZE       (hbm_axi[3].awsize ), //write transaction size
//    .AXI_03_AWVALID      (hbm_axi[3].awvalid), //write address valid
//    .AXI_03_AWREADY      (hbm_axi[3].awready), //write address ready//////////
//    .AXI_03_WDATA        (hbm_axi[3].wdata  ), //write data
//    .AXI_03_WLAST        (hbm_axi[3].wlast  ), //write data last
//    .AXI_03_WSTRB        (hbm_axi[3].wstrb  ), //write data strobe
//    .AXI_03_WVALID       (hbm_axi[3].wvalid ), //write valid
//    .AXI_03_WREADY       (hbm_axi[3].wready ), //write data ready
//    .AXI_03_WDATA_PARITY (     0            ), //////////////////////////////
//    .AXI_03_BID          (hbm_axi[3].bid    ), //write response id
//    .AXI_03_BRESP        (hbm_axi[3].bresp  ), //write response
//    .AXI_03_BVALID       (hbm_axi[3].bvalid ), //write response valid
//    .AXI_03_BREADY       (hbm_axi[3].bready ), //write response ready


//    .AXI_04_ACLK         (hbm_axi[4].clk    ), //clk
//    .AXI_04_ARESET_N     (hbm_axi[4].arstn  ), //resetn
//    .AXI_04_ARADDR       (hbm_axi[4].araddr ), //read address
//    .AXI_04_ARBURST      (hbm_axi[4].arburst), //read burst type: 01
//    .AXI_04_ARID         (hbm_axi[4].arid   ), //read id
//    .AXI_04_ARLEN        (hbm_axi[4].arlen  ), //read burst size
//    .AXI_04_ARSIZE       (hbm_axi[4].arsize ), //3'b101: 256-bit, 
//    .AXI_04_ARVALID      (hbm_axi[4].arvalid), //read address valid
//    .AXI_04_ARREADY      (hbm_axi[4].arready), //read address ready///////////
//    .AXI_04_RDATA        (hbm_axi[4].rdata  ), //read data
//    .AXI_04_RID          (hbm_axi[4].rid    ), //read data id
//    .AXI_04_RLAST        (hbm_axi[4].rlast  ), //read data last
//    .AXI_04_RRESP        (hbm_axi[4].rresp  ), //read data status
//    .AXI_04_RVALID       (hbm_axi[4].rvalid ), //read data valid
//    .AXI_04_RREADY       (hbm_axi[4].rready ), //read data ready
//    .AXI_04_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_04_AWADDR       (hbm_axi[4].awaddr ), //write address
//    .AXI_04_AWBURST      (hbm_axi[4].awburst), //write burst type
//    .AXI_04_AWID         (hbm_axi[4].awid   ), //write id
//    .AXI_04_AWLEN        (hbm_axi[4].awlen  ), //write burst size
//    .AXI_04_AWSIZE       (hbm_axi[4].awsize ), //write transaction size
//    .AXI_04_AWVALID      (hbm_axi[4].awvalid), //write address valid
//    .AXI_04_AWREADY      (hbm_axi[4].awready), //write address ready//////////
//    .AXI_04_WDATA        (hbm_axi[4].wdata  ), //write data
//    .AXI_04_WLAST        (hbm_axi[4].wlast  ), //write data last
//    .AXI_04_WSTRB        (hbm_axi[4].wstrb  ), //write data strobe
//    .AXI_04_WVALID       (hbm_axi[4].wvalid ), //write valid
//    .AXI_04_WREADY       (hbm_axi[4].wready ), //write data ready
//    .AXI_04_WDATA_PARITY (    0             ), //////////////////////////////
//    .AXI_04_BID          (hbm_axi[4].bid    ), //write response id
//    .AXI_04_BRESP        (hbm_axi[4].bresp  ), //write response
//    .AXI_04_BVALID       (hbm_axi[4].bvalid ), //write response valid
//    .AXI_04_BREADY       (hbm_axi[4].bready ), //write response ready

//    .AXI_05_ACLK         (hbm_axi[5].clk    ), //clk
//    .AXI_05_ARESET_N     (hbm_axi[5].arstn  ), //resetn
//    .AXI_05_ARADDR       (hbm_axi[5].araddr ), //read address
//    .AXI_05_ARBURST      (hbm_axi[5].arburst), //read burst type: 01
//    .AXI_05_ARID         (hbm_axi[5].arid   ), //read id
//    .AXI_05_ARLEN        (hbm_axi[5].arlen  ), //read burst size
//    .AXI_05_ARSIZE       (hbm_axi[5].arsize ), //3'b101: 256-bit, 
//    .AXI_05_ARVALID      (hbm_axi[5].arvalid), //read address valid
//    .AXI_05_ARREADY      (hbm_axi[5].arready), //read address ready///////////
//    .AXI_05_RDATA        (hbm_axi[5].rdata  ), //read data
//    .AXI_05_RID          (hbm_axi[5].rid    ), //read data id
//    .AXI_05_RLAST        (hbm_axi[5].rlast  ), //read data last
//    .AXI_05_RRESP        (hbm_axi[5].rresp  ), //read data status
//    .AXI_05_RVALID       (hbm_axi[5].rvalid ), //read data valid
//    .AXI_05_RREADY       (hbm_axi[5].rready ), //read data ready
//    .AXI_05_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_05_AWADDR       (hbm_axi[5].awaddr ), //write address
//    .AXI_05_AWBURST      (hbm_axi[5].awburst), //write burst type
//    .AXI_05_AWID         (hbm_axi[5].awid   ), //write id
//    .AXI_05_AWLEN        (hbm_axi[5].awlen  ), //write burst size
//    .AXI_05_AWSIZE       (hbm_axi[5].awsize ), //write transaction size
//    .AXI_05_AWVALID      (hbm_axi[5].awvalid), //write address valid
//    .AXI_05_AWREADY      (hbm_axi[5].awready), //write address ready//////////
//    .AXI_05_WDATA        (hbm_axi[5].wdata  ), //write data
//    .AXI_05_WLAST        (hbm_axi[5].wlast  ), //write data last
//    .AXI_05_WSTRB        (hbm_axi[5].wstrb  ), //write data strobe
//    .AXI_05_WVALID       (hbm_axi[5].wvalid ), //write valid
//    .AXI_05_WREADY       (hbm_axi[5].wready ), //write data ready
//    .AXI_05_WDATA_PARITY (     0            ), //////////////////////////////
//    .AXI_05_BID          (hbm_axi[5].bid    ), //write response id
//    .AXI_05_BRESP        (hbm_axi[5].bresp  ), //write response
//    .AXI_05_BVALID       (hbm_axi[5].bvalid ), //write response valid
//    .AXI_05_BREADY       (hbm_axi[5].bready ), //write response ready

//    .AXI_06_ACLK         (hbm_axi[6].clk    ), //clk
//    .AXI_06_ARESET_N     (hbm_axi[6].arstn  ), //resetn
//    .AXI_06_ARADDR       (hbm_axi[6].araddr ), //read address
//    .AXI_06_ARBURST      (hbm_axi[6].arburst), //read burst type: 01
//    .AXI_06_ARID         (hbm_axi[6].arid   ), //read id
//    .AXI_06_ARLEN        (hbm_axi[6].arlen  ), //read burst size
//    .AXI_06_ARSIZE       (hbm_axi[6].arsize ), //3'b101: 256-bit, 
//    .AXI_06_ARVALID      (hbm_axi[6].arvalid), //read address valid
//    .AXI_06_ARREADY      (hbm_axi[6].arready), //read address ready///////////
//    .AXI_06_RDATA        (hbm_axi[6].rdata  ), //read data
//    .AXI_06_RID          (hbm_axi[6].rid    ), //read data id
//    .AXI_06_RLAST        (hbm_axi[6].rlast  ), //read data last
//    .AXI_06_RRESP        (hbm_axi[6].rresp  ), //read data status
//    .AXI_06_RVALID       (hbm_axi[6].rvalid ), //read data valid
//    .AXI_06_RREADY       (hbm_axi[6].rready ), //read data ready
//    .AXI_06_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_06_AWADDR       (hbm_axi[6].awaddr ), //write address
//    .AXI_06_AWBURST      (hbm_axi[6].awburst), //write burst type
//    .AXI_06_AWID         (hbm_axi[6].awid   ), //write id
//    .AXI_06_AWLEN        (hbm_axi[6].awlen  ), //write burst size
//    .AXI_06_AWSIZE       (hbm_axi[6].awsize ), //write transaction size
//    .AXI_06_AWVALID      (hbm_axi[6].awvalid), //write address valid
//    .AXI_06_AWREADY      (hbm_axi[6].awready), //write address ready//////////
//    .AXI_06_WDATA        (hbm_axi[6].wdata  ), //write data
//    .AXI_06_WLAST        (hbm_axi[6].wlast  ), //write data last
//    .AXI_06_WSTRB        (hbm_axi[6].wstrb  ), //write data strobe
//    .AXI_06_WVALID       (hbm_axi[6].wvalid ), //write valid
//    .AXI_06_WREADY       (hbm_axi[6].wready ), //write data ready
//    .AXI_06_WDATA_PARITY (     0            ), //////////////////////////////
//    .AXI_06_BID          (hbm_axi[6].bid    ), //write response id
//    .AXI_06_BRESP        (hbm_axi[6].bresp  ), //write response
//    .AXI_06_BVALID       (hbm_axi[6].bvalid ), //write response valid
//    .AXI_06_BREADY       (hbm_axi[6].bready ), //write response ready

//    .AXI_07_ACLK         (hbm_axi[7].clk    ), //clk
//    .AXI_07_ARESET_N     (hbm_axi[7].arstn  ), //resetn
//    .AXI_07_ARADDR       (hbm_axi[7].araddr ), //read address
//    .AXI_07_ARBURST      (hbm_axi[7].arburst), //read burst type: 01
//    .AXI_07_ARID         (hbm_axi[7].arid   ), //read id
//    .AXI_07_ARLEN        (hbm_axi[7].arlen  ), //read burst size
//    .AXI_07_ARSIZE       (hbm_axi[7].arsize ), //3'b101: 256-bit, 
//    .AXI_07_ARVALID      (hbm_axi[7].arvalid), //read address valid
//    .AXI_07_ARREADY      (hbm_axi[7].arready), //read address ready///////////
//    .AXI_07_RDATA        (hbm_axi[7].rdata  ), //read data
//    .AXI_07_RID          (hbm_axi[7].rid    ), //read data id
//    .AXI_07_RLAST        (hbm_axi[7].rlast  ), //read data last
//    .AXI_07_RRESP        (hbm_axi[7].rresp  ), //read data status
//    .AXI_07_RVALID       (hbm_axi[7].rvalid ), //read data valid
//    .AXI_07_RREADY       (hbm_axi[7].rready ), //read data ready
//    .AXI_07_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_07_AWADDR       (hbm_axi[7].awaddr ), //write address
//    .AXI_07_AWBURST      (hbm_axi[7].awburst), //write burst type
//    .AXI_07_AWID         (hbm_axi[7].awid   ), //write id
//    .AXI_07_AWLEN        (hbm_axi[7].awlen  ), //write burst size
//    .AXI_07_AWSIZE       (hbm_axi[7].awsize ), //write transaction size
//    .AXI_07_AWVALID      (hbm_axi[7].awvalid), //write address valid
//    .AXI_07_AWREADY      (hbm_axi[7].awready), //write address ready//////////
//    .AXI_07_WDATA        (hbm_axi[7].wdata  ), //write data
//    .AXI_07_WLAST        (hbm_axi[7].wlast  ), //write data last
//    .AXI_07_WSTRB        (hbm_axi[7].wstrb  ), //write data strobe
//    .AXI_07_WVALID       (hbm_axi[7].wvalid ), //write valid
//    .AXI_07_WREADY       (hbm_axi[7].wready ), //write data ready
//    .AXI_07_WDATA_PARITY (        0         ), //////////////////////////////
//    .AXI_07_BID          (hbm_axi[7].bid    ), //write response id
//    .AXI_07_BRESP        (hbm_axi[7].bresp  ), //write response
//    .AXI_07_BVALID       (hbm_axi[7].bvalid ), //write response valid
//    .AXI_07_BREADY       (hbm_axi[7].bready ), //write response ready

//    .AXI_08_ACLK         (hbm_axi[8].clk    ), //clk
//    .AXI_08_ARESET_N     (hbm_axi[8].arstn  ), //resetn
//    .AXI_08_ARADDR       (hbm_axi[8].araddr ), //read address
//    .AXI_08_ARBURST      (hbm_axi[8].arburst), //read burst type: 01
//    .AXI_08_ARID         (hbm_axi[8].arid   ), //read id
//    .AXI_08_ARLEN        (hbm_axi[8].arlen  ), //read burst size
//    .AXI_08_ARSIZE       (hbm_axi[8].arsize ), //3'b101: 256-bit, 
//    .AXI_08_ARVALID      (hbm_axi[8].arvalid), //read address valid
//    .AXI_08_ARREADY      (hbm_axi[8].arready), //read address ready///////////
//    .AXI_08_RDATA        (hbm_axi[8].rdata  ), //read data
//    .AXI_08_RID          (hbm_axi[8].rid    ), //read data id
//    .AXI_08_RLAST        (hbm_axi[8].rlast  ), //read data last
//    .AXI_08_RRESP        (hbm_axi[8].rresp  ), //read data status
//    .AXI_08_RVALID       (hbm_axi[8].rvalid ), //read data valid
//    .AXI_08_RREADY       (hbm_axi[8].rready ), //read data ready
//    .AXI_08_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_08_AWADDR       (hbm_axi[8].awaddr ), //write address
//    .AXI_08_AWBURST      (hbm_axi[8].awburst), //write burst type
//    .AXI_08_AWID         (hbm_axi[8].awid   ), //write id
//    .AXI_08_AWLEN        (hbm_axi[8].awlen  ), //write burst size
//    .AXI_08_AWSIZE       (hbm_axi[8].awsize ), //write transaction size
//    .AXI_08_AWVALID      (hbm_axi[8].awvalid), //write address valid
//    .AXI_08_AWREADY      (hbm_axi[8].awready), //write address ready//////////
//    .AXI_08_WDATA        (hbm_axi[8].wdata  ), //write data
//    .AXI_08_WLAST        (hbm_axi[8].wlast  ), //write data last
//    .AXI_08_WSTRB        (hbm_axi[8].wstrb  ), //write data strobe
//    .AXI_08_WVALID       (hbm_axi[8].wvalid ), //write valid
//    .AXI_08_WREADY       (hbm_axi[8].wready ), //write data ready
//    .AXI_08_WDATA_PARITY (      0           ), //////////////////////////////
//    .AXI_08_BID          (hbm_axi[8].bid    ), //write response id
//    .AXI_08_BRESP        (hbm_axi[8].bresp  ), //write response
//    .AXI_08_BVALID       (hbm_axi[8].bvalid ), //write response valid
//    .AXI_08_BREADY       (hbm_axi[8].bready ), //write response ready

//    .AXI_09_ACLK         (hbm_axi[9].clk    ), //clk
//    .AXI_09_ARESET_N     (hbm_axi[9].arstn  ), //resetn
//    .AXI_09_ARADDR       (hbm_axi[9].araddr ), //read address
//    .AXI_09_ARBURST      (hbm_axi[9].arburst), //read burst type: 01
//    .AXI_09_ARID         (hbm_axi[9].arid   ), //read id
//    .AXI_09_ARLEN        (hbm_axi[9].arlen  ), //read burst size
//    .AXI_09_ARSIZE       (hbm_axi[9].arsize ), //3'b101: 256-bit, 
//    .AXI_09_ARVALID      (hbm_axi[9].arvalid), //read address valid
//    .AXI_09_ARREADY      (hbm_axi[9].arready), //read address ready///////////
//    .AXI_09_RDATA        (hbm_axi[9].rdata  ), //read data
//    .AXI_09_RID          (hbm_axi[9].rid    ), //read data id
//    .AXI_09_RLAST        (hbm_axi[9].rlast  ), //read data last
//    .AXI_09_RRESP        (hbm_axi[9].rresp  ), //read data status
//    .AXI_09_RVALID       (hbm_axi[9].rvalid ), //read data valid
//    .AXI_09_RREADY       (hbm_axi[9].rready ), //read data ready
//    .AXI_09_RDATA_PARITY (                  ), //read data parity/////////////
//    .AXI_09_AWADDR       (hbm_axi[9].awaddr ), //write address
//    .AXI_09_AWBURST      (hbm_axi[9].awburst), //write burst type
//    .AXI_09_AWID         (hbm_axi[9].awid   ), //write id
//    .AXI_09_AWLEN        (hbm_axi[9].awlen  ), //write burst size
//    .AXI_09_AWSIZE       (hbm_axi[9].awsize ), //write transaction size
//    .AXI_09_AWVALID      (hbm_axi[9].awvalid), //write address valid
//    .AXI_09_AWREADY      (hbm_axi[9].awready), //write address ready//////////
//    .AXI_09_WDATA        (hbm_axi[9].wdata  ), //write data
//    .AXI_09_WLAST        (hbm_axi[9].wlast  ), //write data last
//    .AXI_09_WSTRB        (hbm_axi[9].wstrb  ), //write data strobe
//    .AXI_09_WVALID       (hbm_axi[9].wvalid ), //write valid
//    .AXI_09_WREADY       (hbm_axi[9].wready ), //write data ready
//    .AXI_09_WDATA_PARITY (    0             ), //////////////////////////////
//    .AXI_09_BID          (hbm_axi[9].bid    ), //write response id
//    .AXI_09_BRESP        (hbm_axi[9].bresp  ), //write response
//    .AXI_09_BVALID       (hbm_axi[9].bvalid ), //write response valid
//    .AXI_09_BREADY       (hbm_axi[9].bready ), //write response ready


//    .AXI_10_ACLK         (hbm_axi[10].clk    ), //clk
//    .AXI_10_ARESET_N     (hbm_axi[10].arstn  ), //resetn
//    .AXI_10_ARADDR       (hbm_axi[10].araddr ), //read address
//    .AXI_10_ARBURST      (hbm_axi[10].arburst), //read burst type: 01
//    .AXI_10_ARID         (hbm_axi[10].arid   ), //read id
//    .AXI_10_ARLEN        (hbm_axi[10].arlen  ), //read burst size
//    .AXI_10_ARSIZE       (hbm_axi[10].arsize ), //3'b101: 256-bit, 
//    .AXI_10_ARVALID      (hbm_axi[10].arvalid), //read address valid
//    .AXI_10_ARREADY      (hbm_axi[10].arready), //read address ready///////////
//    .AXI_10_RDATA        (hbm_axi[10].rdata  ), //read data
//    .AXI_10_RID          (hbm_axi[10].rid    ), //read data id
//    .AXI_10_RLAST        (hbm_axi[10].rlast  ), //read data last
//    .AXI_10_RRESP        (hbm_axi[10].rresp  ), //read data status
//    .AXI_10_RVALID       (hbm_axi[10].rvalid ), //read data valid
//    .AXI_10_RREADY       (hbm_axi[10].rready ), //read data ready
//    .AXI_10_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_10_AWADDR       (hbm_axi[10].awaddr ), //write address
//    .AXI_10_AWBURST      (hbm_axi[10].awburst), //write burst type
//    .AXI_10_AWID         (hbm_axi[10].awid   ), //write id
//    .AXI_10_AWLEN        (hbm_axi[10].awlen  ), //write burst size
//    .AXI_10_AWSIZE       (hbm_axi[10].awsize ), //write transaction size
//    .AXI_10_AWVALID      (hbm_axi[10].awvalid), //write address valid
//    .AXI_10_AWREADY      (hbm_axi[10].awready), //write address ready//////////
//    .AXI_10_WDATA        (hbm_axi[10].wdata  ), //write data
//    .AXI_10_WLAST        (hbm_axi[10].wlast  ), //write data last
//    .AXI_10_WSTRB        (hbm_axi[10].wstrb  ), //write data strobe
//    .AXI_10_WVALID       (hbm_axi[10].wvalid ), //write valid
//    .AXI_10_WREADY       (hbm_axi[10].wready ), //write data ready
//    .AXI_10_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_10_BID          (hbm_axi[10].bid    ), //write response id
//    .AXI_10_BRESP        (hbm_axi[10].bresp  ), //write response
//    .AXI_10_BVALID       (hbm_axi[10].bvalid ), //write response valid
//    .AXI_10_BREADY       (hbm_axi[10].bready ), //write response ready

//    .AXI_11_ACLK         (hbm_axi[11].clk    ), //clk
//    .AXI_11_ARESET_N     (hbm_axi[11].arstn  ), //resetn
//    .AXI_11_ARADDR       (hbm_axi[11].araddr ), //read address
//    .AXI_11_ARBURST      (hbm_axi[11].arburst), //read burst type: 01
//    .AXI_11_ARID         (hbm_axi[11].arid   ), //read id
//    .AXI_11_ARLEN        (hbm_axi[11].arlen  ), //read burst size
//    .AXI_11_ARSIZE       (hbm_axi[11].arsize ), //3'b101: 256-bit, 
//    .AXI_11_ARVALID      (hbm_axi[11].arvalid), //read address valid
//    .AXI_11_ARREADY      (hbm_axi[11].arready), //read address ready///////////
//    .AXI_11_RDATA        (hbm_axi[11].rdata  ), //read data
//    .AXI_11_RID          (hbm_axi[11].rid    ), //read data id
//    .AXI_11_RLAST        (hbm_axi[11].rlast  ), //read data last
//    .AXI_11_RRESP        (hbm_axi[11].rresp  ), //read data status
//    .AXI_11_RVALID       (hbm_axi[11].rvalid ), //read data valid
//    .AXI_11_RREADY       (hbm_axi[11].rready ), //read data ready
//    .AXI_11_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_11_AWADDR       (hbm_axi[11].awaddr ), //write address
//    .AXI_11_AWBURST      (hbm_axi[11].awburst), //write burst type
//    .AXI_11_AWID         (hbm_axi[11].awid   ), //write id
//    .AXI_11_AWLEN        (hbm_axi[11].awlen  ), //write burst size
//    .AXI_11_AWSIZE       (hbm_axi[11].awsize ), //write transaction size
//    .AXI_11_AWVALID      (hbm_axi[11].awvalid), //write address valid
//    .AXI_11_AWREADY      (hbm_axi[11].awready), //write address ready//////////
//    .AXI_11_WDATA        (hbm_axi[11].wdata  ), //write data
//    .AXI_11_WLAST        (hbm_axi[11].wlast  ), //write data last
//    .AXI_11_WSTRB        (hbm_axi[11].wstrb  ), //write data strobe
//    .AXI_11_WVALID       (hbm_axi[11].wvalid ), //write valid
//    .AXI_11_WREADY       (hbm_axi[11].wready ), //write data ready
//    .AXI_11_WDATA_PARITY (     0            ), //////////////////////////////
//    .AXI_11_BID          (hbm_axi[11].bid    ), //write response id
//    .AXI_11_BRESP        (hbm_axi[11].bresp  ), //write response
//    .AXI_11_BVALID       (hbm_axi[11].bvalid ), //write response valid
//    .AXI_11_BREADY       (hbm_axi[11].bready ), //write response ready

//    .AXI_12_ACLK         (hbm_axi[12].clk    ), //clk
//    .AXI_12_ARESET_N     (hbm_axi[12].arstn  ), //resetn
//    .AXI_12_ARADDR       (hbm_axi[12].araddr ), //read address
//    .AXI_12_ARBURST      (hbm_axi[12].arburst), //read burst type: 01
//    .AXI_12_ARID         (hbm_axi[12].arid   ), //read id
//    .AXI_12_ARLEN        (hbm_axi[12].arlen  ), //read burst size
//    .AXI_12_ARSIZE       (hbm_axi[12].arsize ), //3'b101: 256-bit, 
//    .AXI_12_ARVALID      (hbm_axi[12].arvalid), //read address valid
//    .AXI_12_ARREADY      (hbm_axi[12].arready), //read address ready///////////
//    .AXI_12_RDATA        (hbm_axi[12].rdata  ), //read data
//    .AXI_12_RID          (hbm_axi[12].rid    ), //read data id
//    .AXI_12_RLAST        (hbm_axi[12].rlast  ), //read data last
//    .AXI_12_RRESP        (hbm_axi[12].rresp  ), //read data status
//    .AXI_12_RVALID       (hbm_axi[12].rvalid ), //read data valid
//    .AXI_12_RREADY       (hbm_axi[12].rready ), //read data ready
//    .AXI_12_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_12_AWADDR       (hbm_axi[12].awaddr ), //write address
//    .AXI_12_AWBURST      (hbm_axi[12].awburst), //write burst type
//    .AXI_12_AWID         (hbm_axi[12].awid   ), //write id
//    .AXI_12_AWLEN        (hbm_axi[12].awlen  ), //write burst size
//    .AXI_12_AWSIZE       (hbm_axi[12].awsize ), //write transaction size
//    .AXI_12_AWVALID      (hbm_axi[12].awvalid), //write address valid
//    .AXI_12_AWREADY      (hbm_axi[12].awready), //write address ready//////////
//    .AXI_12_WDATA        (hbm_axi[12].wdata  ), //write data
//    .AXI_12_WLAST        (hbm_axi[12].wlast  ), //write data last
//    .AXI_12_WSTRB        (hbm_axi[12].wstrb  ), //write data strobe
//    .AXI_12_WVALID       (hbm_axi[12].wvalid ), //write valid
//    .AXI_12_WREADY       (hbm_axi[12].wready ), //write data ready
//    .AXI_12_WDATA_PARITY (      0            ), //////////////////////////////
//    .AXI_12_BID          (hbm_axi[12].bid    ), //write response id
//    .AXI_12_BRESP        (hbm_axi[12].bresp  ), //write response
//    .AXI_12_BVALID       (hbm_axi[12].bvalid ), //write response valid
//    .AXI_12_BREADY       (hbm_axi[12].bready ), //write response ready

//    .AXI_13_ACLK         (hbm_axi[13].clk    ), //clk
//    .AXI_13_ARESET_N     (hbm_axi[13].arstn  ), //resetn
//    .AXI_13_ARADDR       (hbm_axi[13].araddr ), //read address
//    .AXI_13_ARBURST      (hbm_axi[13].arburst), //read burst type: 01
//    .AXI_13_ARID         (hbm_axi[13].arid   ), //read id
//    .AXI_13_ARLEN        (hbm_axi[13].arlen  ), //read burst size
//    .AXI_13_ARSIZE       (hbm_axi[13].arsize ), //3'b101: 256-bit, 
//    .AXI_13_ARVALID      (hbm_axi[13].arvalid), //read address valid
//    .AXI_13_ARREADY      (hbm_axi[13].arready), //read address ready///////////
//    .AXI_13_RDATA        (hbm_axi[13].rdata  ), //read data
//    .AXI_13_RID          (hbm_axi[13].rid    ), //read data id
//    .AXI_13_RLAST        (hbm_axi[13].rlast  ), //read data last
//    .AXI_13_RRESP        (hbm_axi[13].rresp  ), //read data status
//    .AXI_13_RVALID       (hbm_axi[13].rvalid ), //read data valid
//    .AXI_13_RREADY       (hbm_axi[13].rready ), //read data ready
//    .AXI_13_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_13_AWADDR       (hbm_axi[13].awaddr ), //write address
//    .AXI_13_AWBURST      (hbm_axi[13].awburst), //write burst type
//    .AXI_13_AWID         (hbm_axi[13].awid   ), //write id
//    .AXI_13_AWLEN        (hbm_axi[13].awlen  ), //write burst size
//    .AXI_13_AWSIZE       (hbm_axi[13].awsize ), //write transaction size
//    .AXI_13_AWVALID      (hbm_axi[13].awvalid), //write address valid
//    .AXI_13_AWREADY      (hbm_axi[13].awready), //write address ready//////////
//    .AXI_13_WDATA        (hbm_axi[13].wdata  ), //write data
//    .AXI_13_WLAST        (hbm_axi[13].wlast  ), //write data last
//    .AXI_13_WSTRB        (hbm_axi[13].wstrb  ), //write data strobe
//    .AXI_13_WVALID       (hbm_axi[13].wvalid ), //write valid
//    .AXI_13_WREADY       (hbm_axi[13].wready ), //write data ready
//    .AXI_13_WDATA_PARITY (       0           ), //////////////////////////////
//    .AXI_13_BID          (hbm_axi[13].bid    ), //write response id
//    .AXI_13_BRESP        (hbm_axi[13].bresp  ), //write response
//    .AXI_13_BVALID       (hbm_axi[13].bvalid ), //write response valid
//    .AXI_13_BREADY       (hbm_axi[13].bready ), //write response ready


//    .AXI_14_ACLK         (hbm_axi[14].clk    ), //clk
//    .AXI_14_ARESET_N     (hbm_axi[14].arstn  ), //resetn
//    .AXI_14_ARADDR       (hbm_axi[14].araddr ), //read address
//    .AXI_14_ARBURST      (hbm_axi[14].arburst), //read burst type: 01
//    .AXI_14_ARID         (hbm_axi[14].arid   ), //read id
//    .AXI_14_ARLEN        (hbm_axi[14].arlen  ), //read burst size
//    .AXI_14_ARSIZE       (hbm_axi[14].arsize ), //3'b101: 256-bit, 
//    .AXI_14_ARVALID      (hbm_axi[14].arvalid), //read address valid
//    .AXI_14_ARREADY      (hbm_axi[14].arready), //read address ready///////////
//    .AXI_14_RDATA        (hbm_axi[14].rdata  ), //read data
//    .AXI_14_RID          (hbm_axi[14].rid    ), //read data id
//    .AXI_14_RLAST        (hbm_axi[14].rlast  ), //read data last
//    .AXI_14_RRESP        (hbm_axi[14].rresp  ), //read data status
//    .AXI_14_RVALID       (hbm_axi[14].rvalid ), //read data valid
//    .AXI_14_RREADY       (hbm_axi[14].rready ), //read data ready
//    .AXI_14_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_14_AWADDR       (hbm_axi[14].awaddr ), //write address
//    .AXI_14_AWBURST      (hbm_axi[14].awburst), //write burst type
//    .AXI_14_AWID         (hbm_axi[14].awid   ), //write id
//    .AXI_14_AWLEN        (hbm_axi[14].awlen  ), //write burst size
//    .AXI_14_AWSIZE       (hbm_axi[14].awsize ), //write transaction size
//    .AXI_14_AWVALID      (hbm_axi[14].awvalid), //write address valid
//    .AXI_14_AWREADY      (hbm_axi[14].awready), //write address ready//////////
//    .AXI_14_WDATA        (hbm_axi[14].wdata  ), //write data
//    .AXI_14_WLAST        (hbm_axi[14].wlast  ), //write data last
//    .AXI_14_WSTRB        (hbm_axi[14].wstrb  ), //write data strobe
//    .AXI_14_WVALID       (hbm_axi[14].wvalid ), //write valid
//    .AXI_14_WREADY       (hbm_axi[14].wready ), //write data ready
//    .AXI_14_WDATA_PARITY (         0         ), //////////////////////////////
//    .AXI_14_BID          (hbm_axi[14].bid    ), //write response id
//    .AXI_14_BRESP        (hbm_axi[14].bresp  ), //write response
//    .AXI_14_BVALID       (hbm_axi[14].bvalid ), //write response valid
//    .AXI_14_BREADY       (hbm_axi[14].bready ), //write response ready

//    .AXI_15_ACLK         (hbm_axi[15].clk    ), //clk
//    .AXI_15_ARESET_N     (hbm_axi[15].arstn  ), //resetn
//    .AXI_15_ARADDR       (hbm_axi[15].araddr ), //read address
//    .AXI_15_ARBURST      (hbm_axi[15].arburst), //read burst type: 01
//    .AXI_15_ARID         (hbm_axi[15].arid   ), //read id
//    .AXI_15_ARLEN        (hbm_axi[15].arlen  ), //read burst size
//    .AXI_15_ARSIZE       (hbm_axi[15].arsize ), //3'b101: 256-bit, 
//    .AXI_15_ARVALID      (hbm_axi[15].arvalid), //read address valid
//    .AXI_15_ARREADY      (hbm_axi[15].arready), //read address ready///////////
//    .AXI_15_RDATA        (hbm_axi[15].rdata  ), //read data
//    .AXI_15_RID          (hbm_axi[15].rid    ), //read data id
//    .AXI_15_RLAST        (hbm_axi[15].rlast  ), //read data last
//    .AXI_15_RRESP        (hbm_axi[15].rresp  ), //read data status
//    .AXI_15_RVALID       (hbm_axi[15].rvalid ), //read data valid
//    .AXI_15_RREADY       (hbm_axi[15].rready ), //read data ready
//    .AXI_15_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_15_AWADDR       (hbm_axi[15].awaddr ), //write address
//    .AXI_15_AWBURST      (hbm_axi[15].awburst), //write burst type
//    .AXI_15_AWID         (hbm_axi[15].awid   ), //write id
//    .AXI_15_AWLEN        (hbm_axi[15].awlen  ), //write burst size
//    .AXI_15_AWSIZE       (hbm_axi[15].awsize ), //write transaction size
//    .AXI_15_AWVALID      (hbm_axi[15].awvalid), //write address valid
//    .AXI_15_AWREADY      (hbm_axi[15].awready), //write address ready//////////
//    .AXI_15_WDATA        (hbm_axi[15].wdata  ), //write data
//    .AXI_15_WLAST        (hbm_axi[15].wlast  ), //write data last
//    .AXI_15_WSTRB        (hbm_axi[15].wstrb  ), //write data strobe
//    .AXI_15_WVALID       (hbm_axi[15].wvalid ), //write valid
//    .AXI_15_WREADY       (hbm_axi[15].wready ), //write data ready
//    .AXI_15_WDATA_PARITY (       0           ), //////////////////////////////
//    .AXI_15_BID          (hbm_axi[15].bid    ), //write response id
//    .AXI_15_BRESP        (hbm_axi[15].bresp  ), //write response
//    .AXI_15_BVALID       (hbm_axi[15].bvalid ), //write response valid
//    .AXI_15_BREADY       (hbm_axi[15].bready ), //write response ready

//    .AXI_16_ACLK         (hbm_axi[16].clk    ), //clk
//    .AXI_16_ARESET_N     (hbm_axi[16].arstn  ), //resetn
//    .AXI_16_ARADDR       (hbm_axi[16].araddr ), //read address
//    .AXI_16_ARBURST      (hbm_axi[16].arburst), //read burst type: 01
//    .AXI_16_ARID         (hbm_axi[16].arid   ), //read id
//    .AXI_16_ARLEN        (hbm_axi[16].arlen  ), //read burst size
//    .AXI_16_ARSIZE       (hbm_axi[16].arsize ), //3'b101: 256-bit, 
//    .AXI_16_ARVALID      (hbm_axi[16].arvalid), //read address valid
//    .AXI_16_ARREADY      (hbm_axi[16].arready), //read address ready///////////
//    .AXI_16_RDATA        (hbm_axi[16].rdata  ), //read data
//    .AXI_16_RID          (hbm_axi[16].rid    ), //read data id
//    .AXI_16_RLAST        (hbm_axi[16].rlast  ), //read data last
//    .AXI_16_RRESP        (hbm_axi[16].rresp  ), //read data status
//    .AXI_16_RVALID       (hbm_axi[16].rvalid ), //read data valid
//    .AXI_16_RREADY       (hbm_axi[16].rready ), //read data ready
//    .AXI_16_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_16_AWADDR       (hbm_axi[16].awaddr ), //write address
//    .AXI_16_AWBURST      (hbm_axi[16].awburst), //write burst type
//    .AXI_16_AWID         (hbm_axi[16].awid   ), //write id
//    .AXI_16_AWLEN        (hbm_axi[16].awlen  ), //write burst size
//    .AXI_16_AWSIZE       (hbm_axi[16].awsize ), //write transaction size
//    .AXI_16_AWVALID      (hbm_axi[16].awvalid), //write address valid
//    .AXI_16_AWREADY      (hbm_axi[16].awready), //write address ready//////////
//    .AXI_16_WDATA        (hbm_axi[16].wdata  ), //write data
//    .AXI_16_WLAST        (hbm_axi[16].wlast  ), //write data last
//    .AXI_16_WSTRB        (hbm_axi[16].wstrb  ), //write data strobe
//    .AXI_16_WVALID       (hbm_axi[16].wvalid ), //write valid
//    .AXI_16_WREADY       (hbm_axi[16].wready ), //write data ready
//    .AXI_16_WDATA_PARITY (         0         ), //////////////////////////////
//    .AXI_16_BID          (hbm_axi[16].bid    ), //write response id
//    .AXI_16_BRESP        (hbm_axi[16].bresp  ), //write response
//    .AXI_16_BVALID       (hbm_axi[16].bvalid ), //write response valid
//    .AXI_16_BREADY       (hbm_axi[16].bready ), //write response ready

//    .AXI_17_ACLK         (hbm_axi[17].clk    ), //clk
//    .AXI_17_ARESET_N     (hbm_axi[17].arstn  ), //resetn
//    .AXI_17_ARADDR       (hbm_axi[17].araddr ), //read address
//    .AXI_17_ARBURST      (hbm_axi[17].arburst), //read burst type: 01
//    .AXI_17_ARID         (hbm_axi[17].arid   ), //read id
//    .AXI_17_ARLEN        (hbm_axi[17].arlen  ), //read burst size
//    .AXI_17_ARSIZE       (hbm_axi[17].arsize ), //3'b101: 256-bit, 
//    .AXI_17_ARVALID      (hbm_axi[17].arvalid), //read address valid
//    .AXI_17_ARREADY      (hbm_axi[17].arready), //read address ready///////////
//    .AXI_17_RDATA        (hbm_axi[17].rdata  ), //read data
//    .AXI_17_RID          (hbm_axi[17].rid    ), //read data id
//    .AXI_17_RLAST        (hbm_axi[17].rlast  ), //read data last
//    .AXI_17_RRESP        (hbm_axi[17].rresp  ), //read data status
//    .AXI_17_RVALID       (hbm_axi[17].rvalid ), //read data valid
//    .AXI_17_RREADY       (hbm_axi[17].rready ), //read data ready
//    .AXI_17_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_17_AWADDR       (hbm_axi[17].awaddr ), //write address
//    .AXI_17_AWBURST      (hbm_axi[17].awburst), //write burst type
//    .AXI_17_AWID         (hbm_axi[17].awid   ), //write id
//    .AXI_17_AWLEN        (hbm_axi[17].awlen  ), //write burst size
//    .AXI_17_AWSIZE       (hbm_axi[17].awsize ), //write transaction size
//    .AXI_17_AWVALID      (hbm_axi[17].awvalid), //write address valid
//    .AXI_17_AWREADY      (hbm_axi[17].awready), //write address ready//////////
//    .AXI_17_WDATA        (hbm_axi[17].wdata  ), //write data
//    .AXI_17_WLAST        (hbm_axi[17].wlast  ), //write data last
//    .AXI_17_WSTRB        (hbm_axi[17].wstrb  ), //write data strobe
//    .AXI_17_WVALID       (hbm_axi[17].wvalid ), //write valid
//    .AXI_17_WREADY       (hbm_axi[17].wready ), //write data ready
//    .AXI_17_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_17_BID          (hbm_axi[17].bid    ), //write response id
//    .AXI_17_BRESP        (hbm_axi[17].bresp  ), //write response
//    .AXI_17_BVALID       (hbm_axi[17].bvalid ), //write response valid
//    .AXI_17_BREADY       (hbm_axi[17].bready ), //write response ready

//    .AXI_18_ACLK         (hbm_axi[18].clk    ), //clk
//    .AXI_18_ARESET_N     (hbm_axi[18].arstn  ), //resetn
//    .AXI_18_ARADDR       (hbm_axi[18].araddr ), //read address
//    .AXI_18_ARBURST      (hbm_axi[18].arburst), //read burst type: 01
//    .AXI_18_ARID         (hbm_axi[18].arid   ), //read id
//    .AXI_18_ARLEN        (hbm_axi[18].arlen  ), //read burst size
//    .AXI_18_ARSIZE       (hbm_axi[18].arsize ), //3'b101: 256-bit, 
//    .AXI_18_ARVALID      (hbm_axi[18].arvalid), //read address valid
//    .AXI_18_ARREADY      (hbm_axi[18].arready), //read address ready///////////
//    .AXI_18_RDATA        (hbm_axi[18].rdata  ), //read data
//    .AXI_18_RID          (hbm_axi[18].rid    ), //read data id
//    .AXI_18_RLAST        (hbm_axi[18].rlast  ), //read data last
//    .AXI_18_RRESP        (hbm_axi[18].rresp  ), //read data status
//    .AXI_18_RVALID       (hbm_axi[18].rvalid ), //read data valid
//    .AXI_18_RREADY       (hbm_axi[18].rready ), //read data ready
//    .AXI_18_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_18_AWADDR       (hbm_axi[18].awaddr ), //write address
//    .AXI_18_AWBURST      (hbm_axi[18].awburst), //write burst type
//    .AXI_18_AWID         (hbm_axi[18].awid   ), //write id
//    .AXI_18_AWLEN        (hbm_axi[18].awlen  ), //write burst size
//    .AXI_18_AWSIZE       (hbm_axi[18].awsize ), //write transaction size
//    .AXI_18_AWVALID      (hbm_axi[18].awvalid), //write address valid
//    .AXI_18_AWREADY      (hbm_axi[18].awready), //write address ready//////////
//    .AXI_18_WDATA        (hbm_axi[18].wdata  ), //write data
//    .AXI_18_WLAST        (hbm_axi[18].wlast  ), //write data last
//    .AXI_18_WSTRB        (hbm_axi[18].wstrb  ), //write data strobe
//    .AXI_18_WVALID       (hbm_axi[18].wvalid ), //write valid
//    .AXI_18_WREADY       (hbm_axi[18].wready ), //write data ready
//    .AXI_18_WDATA_PARITY (       0           ), //////////////////////////////
//    .AXI_18_BID          (hbm_axi[18].bid    ), //write response id
//    .AXI_18_BRESP        (hbm_axi[18].bresp  ), //write response
//    .AXI_18_BVALID       (hbm_axi[18].bvalid ), //write response valid
//    .AXI_18_BREADY       (hbm_axi[18].bready ), //write response ready

//    .AXI_19_ACLK         (hbm_axi[19].clk    ), //clk
//    .AXI_19_ARESET_N     (hbm_axi[19].arstn  ), //resetn
//    .AXI_19_ARADDR       (hbm_axi[19].araddr ), //read address
//    .AXI_19_ARBURST      (hbm_axi[19].arburst), //read burst type: 01
//    .AXI_19_ARID         (hbm_axi[19].arid   ), //read id
//    .AXI_19_ARLEN        (hbm_axi[19].arlen  ), //read burst size
//    .AXI_19_ARSIZE       (hbm_axi[19].arsize ), //3'b101: 256-bit, 
//    .AXI_19_ARVALID      (hbm_axi[19].arvalid), //read address valid
//    .AXI_19_ARREADY      (hbm_axi[19].arready), //read address ready///////////
//    .AXI_19_RDATA        (hbm_axi[19].rdata  ), //read data
//    .AXI_19_RID          (hbm_axi[19].rid    ), //read data id
//    .AXI_19_RLAST        (hbm_axi[19].rlast  ), //read data last
//    .AXI_19_RRESP        (hbm_axi[19].rresp  ), //read data status
//    .AXI_19_RVALID       (hbm_axi[19].rvalid ), //read data valid
//    .AXI_19_RREADY       (hbm_axi[19].rready ), //read data ready
//    .AXI_19_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_19_AWADDR       (hbm_axi[19].awaddr ), //write address
//    .AXI_19_AWBURST      (hbm_axi[19].awburst), //write burst type
//    .AXI_19_AWID         (hbm_axi[19].awid   ), //write id
//    .AXI_19_AWLEN        (hbm_axi[19].awlen  ), //write burst size
//    .AXI_19_AWSIZE       (hbm_axi[19].awsize ), //write transaction size
//    .AXI_19_AWVALID      (hbm_axi[19].awvalid), //write address valid
//    .AXI_19_AWREADY      (hbm_axi[19].awready), //write address ready//////////
//    .AXI_19_WDATA        (hbm_axi[19].wdata  ), //write data
//    .AXI_19_WLAST        (hbm_axi[19].wlast  ), //write data last
//    .AXI_19_WSTRB        (hbm_axi[19].wstrb  ), //write data strobe
//    .AXI_19_WVALID       (hbm_axi[19].wvalid ), //write valid
//    .AXI_19_WREADY       (hbm_axi[19].wready ), //write data ready
//    .AXI_19_WDATA_PARITY (       0           ), //////////////////////////////
//    .AXI_19_BID          (hbm_axi[19].bid    ), //write response id
//    .AXI_19_BRESP        (hbm_axi[19].bresp  ), //write response
//    .AXI_19_BVALID       (hbm_axi[19].bvalid ), //write response valid
//    .AXI_19_BREADY       (hbm_axi[19].bready ), //write response ready

//    .AXI_20_ACLK         (hbm_axi[20].clk    ), //clk
//    .AXI_20_ARESET_N     (hbm_axi[20].arstn  ), //resetn
//    .AXI_20_ARADDR       (hbm_axi[20].araddr ), //read address
//    .AXI_20_ARBURST      (hbm_axi[20].arburst), //read burst type: 01
//    .AXI_20_ARID         (hbm_axi[20].arid   ), //read id
//    .AXI_20_ARLEN        (hbm_axi[20].arlen  ), //read burst size
//    .AXI_20_ARSIZE       (hbm_axi[20].arsize ), //3'b101: 256-bit, 
//    .AXI_20_ARVALID      (hbm_axi[20].arvalid), //read address valid
//    .AXI_20_ARREADY      (hbm_axi[20].arready), //read address ready///////////
//    .AXI_20_RDATA        (hbm_axi[20].rdata  ), //read data
//    .AXI_20_RID          (hbm_axi[20].rid    ), //read data id
//    .AXI_20_RLAST        (hbm_axi[20].rlast  ), //read data last
//    .AXI_20_RRESP        (hbm_axi[20].rresp  ), //read data status
//    .AXI_20_RVALID       (hbm_axi[20].rvalid ), //read data valid
//    .AXI_20_RREADY       (hbm_axi[20].rready ), //read data ready
//    .AXI_20_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_20_AWADDR       (hbm_axi[20].awaddr ), //write address
//    .AXI_20_AWBURST      (hbm_axi[20].awburst), //write burst type
//    .AXI_20_AWID         (hbm_axi[20].awid   ), //write id
//    .AXI_20_AWLEN        (hbm_axi[20].awlen  ), //write burst size
//    .AXI_20_AWSIZE       (hbm_axi[20].awsize ), //write transaction size
//    .AXI_20_AWVALID      (hbm_axi[20].awvalid), //write address valid
//    .AXI_20_AWREADY      (hbm_axi[20].awready), //write address ready//////////
//    .AXI_20_WDATA        (hbm_axi[20].wdata  ), //write data
//    .AXI_20_WLAST        (hbm_axi[20].wlast  ), //write data last
//    .AXI_20_WSTRB        (hbm_axi[20].wstrb  ), //write data strobe
//    .AXI_20_WVALID       (hbm_axi[20].wvalid ), //write valid
//    .AXI_20_WREADY       (hbm_axi[20].wready ), //write data ready
//    .AXI_20_WDATA_PARITY (    0              ), //////////////////////////////
//    .AXI_20_BID          (hbm_axi[20].bid    ), //write response id
//    .AXI_20_BRESP        (hbm_axi[20].bresp  ), //write response
//    .AXI_20_BVALID       (hbm_axi[20].bvalid ), //write response valid
//    .AXI_20_BREADY       (hbm_axi[20].bready ), //write response ready

//    .AXI_21_ACLK         (hbm_axi[21].clk    ), //clk
//    .AXI_21_ARESET_N     (hbm_axi[21].arstn  ), //resetn
//    .AXI_21_ARADDR       (hbm_axi[21].araddr ), //read address
//    .AXI_21_ARBURST      (hbm_axi[21].arburst), //read burst type: 01
//    .AXI_21_ARID         (hbm_axi[21].arid   ), //read id
//    .AXI_21_ARLEN        (hbm_axi[21].arlen  ), //read burst size
//    .AXI_21_ARSIZE       (hbm_axi[21].arsize ), //3'b101: 256-bit, 
//    .AXI_21_ARVALID      (hbm_axi[21].arvalid), //read address valid
//    .AXI_21_ARREADY      (hbm_axi[21].arready), //read address ready///////////
//    .AXI_21_RDATA        (hbm_axi[21].rdata  ), //read data
//    .AXI_21_RID          (hbm_axi[21].rid    ), //read data id
//    .AXI_21_RLAST        (hbm_axi[21].rlast  ), //read data last
//    .AXI_21_RRESP        (hbm_axi[21].rresp  ), //read data status
//    .AXI_21_RVALID       (hbm_axi[21].rvalid ), //read data valid
//    .AXI_21_RREADY       (hbm_axi[21].rready ), //read data ready
//    .AXI_21_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_21_AWADDR       (hbm_axi[21].awaddr ), //write address
//    .AXI_21_AWBURST      (hbm_axi[21].awburst), //write burst type
//    .AXI_21_AWID         (hbm_axi[21].awid   ), //write id
//    .AXI_21_AWLEN        (hbm_axi[21].awlen  ), //write burst size
//    .AXI_21_AWSIZE       (hbm_axi[21].awsize ), //write transaction size
//    .AXI_21_AWVALID      (hbm_axi[21].awvalid), //write address valid
//    .AXI_21_AWREADY      (hbm_axi[21].awready), //write address ready//////////
//    .AXI_21_WDATA        (hbm_axi[21].wdata  ), //write data
//    .AXI_21_WLAST        (hbm_axi[21].wlast  ), //write data last
//    .AXI_21_WSTRB        (hbm_axi[21].wstrb  ), //write data strobe
//    .AXI_21_WVALID       (hbm_axi[21].wvalid ), //write valid
//    .AXI_21_WREADY       (hbm_axi[21].wready ), //write data ready
//    .AXI_21_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_21_BID          (hbm_axi[21].bid    ), //write response id
//    .AXI_21_BRESP        (hbm_axi[21].bresp  ), //write response
//    .AXI_21_BVALID       (hbm_axi[21].bvalid ), //write response valid
//    .AXI_21_BREADY       (hbm_axi[21].bready ), //write response ready

//    .AXI_22_ACLK         (hbm_axi[22].clk    ), //clk
//    .AXI_22_ARESET_N     (hbm_axi[22].arstn  ), //resetn
//    .AXI_22_ARADDR       (hbm_axi[22].araddr ), //read address
//    .AXI_22_ARBURST      (hbm_axi[22].arburst), //read burst type: 01
//    .AXI_22_ARID         (hbm_axi[22].arid   ), //read id
//    .AXI_22_ARLEN        (hbm_axi[22].arlen  ), //read burst size
//    .AXI_22_ARSIZE       (hbm_axi[22].arsize ), //3'b101: 256-bit, 
//    .AXI_22_ARVALID      (hbm_axi[22].arvalid), //read address valid
//    .AXI_22_ARREADY      (hbm_axi[22].arready), //read address ready///////////
//    .AXI_22_RDATA        (hbm_axi[22].rdata  ), //read data
//    .AXI_22_RID          (hbm_axi[22].rid    ), //read data id
//    .AXI_22_RLAST        (hbm_axi[22].rlast  ), //read data last
//    .AXI_22_RRESP        (hbm_axi[22].rresp  ), //read data status
//    .AXI_22_RVALID       (hbm_axi[22].rvalid ), //read data valid
//    .AXI_22_RREADY       (hbm_axi[22].rready ), //read data ready
//    .AXI_22_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_22_AWADDR       (hbm_axi[22].awaddr ), //write address
//    .AXI_22_AWBURST      (hbm_axi[22].awburst), //write burst type
//    .AXI_22_AWID         (hbm_axi[22].awid   ), //write id
//    .AXI_22_AWLEN        (hbm_axi[22].awlen  ), //write burst size
//    .AXI_22_AWSIZE       (hbm_axi[22].awsize ), //write transaction size
//    .AXI_22_AWVALID      (hbm_axi[22].awvalid), //write address valid
//    .AXI_22_AWREADY      (hbm_axi[22].awready), //write address ready//////////
//    .AXI_22_WDATA        (hbm_axi[22].wdata  ), //write data
//    .AXI_22_WLAST        (hbm_axi[22].wlast  ), //write data last
//    .AXI_22_WSTRB        (hbm_axi[22].wstrb  ), //write data strobe
//    .AXI_22_WVALID       (hbm_axi[22].wvalid ), //write valid
//    .AXI_22_WREADY       (hbm_axi[22].wready ), //write data ready
//    .AXI_22_WDATA_PARITY (       0           ), //////////////////////////////
//    .AXI_22_BID          (hbm_axi[22].bid    ), //write response id
//    .AXI_22_BRESP        (hbm_axi[22].bresp  ), //write response
//    .AXI_22_BVALID       (hbm_axi[22].bvalid ), //write response valid
//    .AXI_22_BREADY       (hbm_axi[22].bready ), //write response ready

//    .AXI_23_ACLK         (hbm_axi[23].clk    ), //clk
//    .AXI_23_ARESET_N     (hbm_axi[23].arstn  ), //resetn
//    .AXI_23_ARADDR       (hbm_axi[23].araddr ), //read address
//    .AXI_23_ARBURST      (hbm_axi[23].arburst), //read burst type: 01
//    .AXI_23_ARID         (hbm_axi[23].arid   ), //read id
//    .AXI_23_ARLEN        (hbm_axi[23].arlen  ), //read burst size
//    .AXI_23_ARSIZE       (hbm_axi[23].arsize ), //3'b101: 256-bit, 
//    .AXI_23_ARVALID      (hbm_axi[23].arvalid), //read address valid
//    .AXI_23_ARREADY      (hbm_axi[23].arready), //read address ready///////////
//    .AXI_23_RDATA        (hbm_axi[23].rdata  ), //read data
//    .AXI_23_RID          (hbm_axi[23].rid    ), //read data id
//    .AXI_23_RLAST        (hbm_axi[23].rlast  ), //read data last
//    .AXI_23_RRESP        (hbm_axi[23].rresp  ), //read data status
//    .AXI_23_RVALID       (hbm_axi[23].rvalid ), //read data valid
//    .AXI_23_RREADY       (hbm_axi[23].rready ), //read data ready
//    .AXI_23_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_23_AWADDR       (hbm_axi[23].awaddr ), //write address
//    .AXI_23_AWBURST      (hbm_axi[23].awburst), //write burst type
//    .AXI_23_AWID         (hbm_axi[23].awid   ), //write id
//    .AXI_23_AWLEN        (hbm_axi[23].awlen  ), //write burst size
//    .AXI_23_AWSIZE       (hbm_axi[23].awsize ), //write transaction size
//    .AXI_23_AWVALID      (hbm_axi[23].awvalid), //write address valid
//    .AXI_23_AWREADY      (hbm_axi[23].awready), //write address ready//////////
//    .AXI_23_WDATA        (hbm_axi[23].wdata  ), //write data
//    .AXI_23_WLAST        (hbm_axi[23].wlast  ), //write data last
//    .AXI_23_WSTRB        (hbm_axi[23].wstrb  ), //write data strobe
//    .AXI_23_WVALID       (hbm_axi[23].wvalid ), //write valid
//    .AXI_23_WREADY       (hbm_axi[23].wready ), //write data ready
//    .AXI_23_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_23_BID          (hbm_axi[23].bid    ), //write response id
//    .AXI_23_BRESP        (hbm_axi[23].bresp  ), //write response
//    .AXI_23_BVALID       (hbm_axi[23].bvalid ), //write response valid
//    .AXI_23_BREADY       (hbm_axi[23].bready ), //write response ready


//    .AXI_24_ACLK         (hbm_axi[24].clk    ), //clk
//    .AXI_24_ARESET_N     (hbm_axi[24].arstn  ), //resetn
//    .AXI_24_ARADDR       (hbm_axi[24].araddr ), //read address
//    .AXI_24_ARBURST      (hbm_axi[24].arburst), //read burst type: 01
//    .AXI_24_ARID         (hbm_axi[24].arid   ), //read id
//    .AXI_24_ARLEN        (hbm_axi[24].arlen  ), //read burst size
//    .AXI_24_ARSIZE       (hbm_axi[24].arsize ), //3'b101: 256-bit, 
//    .AXI_24_ARVALID      (hbm_axi[24].arvalid), //read address valid
//    .AXI_24_ARREADY      (hbm_axi[24].arready), //read address ready///////////
//    .AXI_24_RDATA        (hbm_axi[24].rdata  ), //read data
//    .AXI_24_RID          (hbm_axi[24].rid    ), //read data id
//    .AXI_24_RLAST        (hbm_axi[24].rlast  ), //read data last
//    .AXI_24_RRESP        (hbm_axi[24].rresp  ), //read data status
//    .AXI_24_RVALID       (hbm_axi[24].rvalid ), //read data valid
//    .AXI_24_RREADY       (hbm_axi[24].rready ), //read data ready
//    .AXI_24_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_24_AWADDR       (hbm_axi[24].awaddr ), //write address
//    .AXI_24_AWBURST      (hbm_axi[24].awburst), //write burst type
//    .AXI_24_AWID         (hbm_axi[24].awid   ), //write id
//    .AXI_24_AWLEN        (hbm_axi[24].awlen  ), //write burst size
//    .AXI_24_AWSIZE       (hbm_axi[24].awsize ), //write transaction size
//    .AXI_24_AWVALID      (hbm_axi[24].awvalid), //write address valid
//    .AXI_24_AWREADY      (hbm_axi[24].awready), //write address ready//////////
//    .AXI_24_WDATA        (hbm_axi[24].wdata  ), //write data
//    .AXI_24_WLAST        (hbm_axi[24].wlast  ), //write data last
//    .AXI_24_WSTRB        (hbm_axi[24].wstrb  ), //write data strobe
//    .AXI_24_WVALID       (hbm_axi[24].wvalid ), //write valid
//    .AXI_24_WREADY       (hbm_axi[24].wready ), //write data ready
//    .AXI_24_WDATA_PARITY (      0            ), //////////////////////////////
//    .AXI_24_BID          (hbm_axi[24].bid    ), //write response id
//    .AXI_24_BRESP        (hbm_axi[24].bresp  ), //write response
//    .AXI_24_BVALID       (hbm_axi[24].bvalid ), //write response valid
//    .AXI_24_BREADY       (hbm_axi[24].bready ), //write response ready

//    .AXI_25_ACLK         (hbm_axi[25].clk    ), //clk
//    .AXI_25_ARESET_N     (hbm_axi[25].arstn  ), //resetn
//    .AXI_25_ARADDR       (hbm_axi[25].araddr ), //read address
//    .AXI_25_ARBURST      (hbm_axi[25].arburst), //read burst type: 01
//    .AXI_25_ARID         (hbm_axi[25].arid   ), //read id
//    .AXI_25_ARLEN        (hbm_axi[25].arlen  ), //read burst size
//    .AXI_25_ARSIZE       (hbm_axi[25].arsize ), //3'b101: 256-bit, 
//    .AXI_25_ARVALID      (hbm_axi[25].arvalid), //read address valid
//    .AXI_25_ARREADY      (hbm_axi[25].arready), //read address ready///////////
//    .AXI_25_RDATA        (hbm_axi[25].rdata  ), //read data
//    .AXI_25_RID          (hbm_axi[25].rid    ), //read data id
//    .AXI_25_RLAST        (hbm_axi[25].rlast  ), //read data last
//    .AXI_25_RRESP        (hbm_axi[25].rresp  ), //read data status
//    .AXI_25_RVALID       (hbm_axi[25].rvalid ), //read data valid
//    .AXI_25_RREADY       (hbm_axi[25].rready ), //read data ready
//    .AXI_25_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_25_AWADDR       (hbm_axi[25].awaddr ), //write address
//    .AXI_25_AWBURST      (hbm_axi[25].awburst), //write burst type
//    .AXI_25_AWID         (hbm_axi[25].awid   ), //write id
//    .AXI_25_AWLEN        (hbm_axi[25].awlen  ), //write burst size
//    .AXI_25_AWSIZE       (hbm_axi[25].awsize ), //write transaction size
//    .AXI_25_AWVALID      (hbm_axi[25].awvalid), //write address valid
//    .AXI_25_AWREADY      (hbm_axi[25].awready), //write address ready//////////
//    .AXI_25_WDATA        (hbm_axi[25].wdata  ), //write data
//    .AXI_25_WLAST        (hbm_axi[25].wlast  ), //write data last
//    .AXI_25_WSTRB        (hbm_axi[25].wstrb  ), //write data strobe
//    .AXI_25_WVALID       (hbm_axi[25].wvalid ), //write valid
//    .AXI_25_WREADY       (hbm_axi[25].wready ), //write data ready
//    .AXI_25_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_25_BID          (hbm_axi[25].bid    ), //write response id
//    .AXI_25_BRESP        (hbm_axi[25].bresp  ), //write response
//    .AXI_25_BVALID       (hbm_axi[25].bvalid ), //write response valid
//    .AXI_25_BREADY       (hbm_axi[25].bready ), //write response ready

//    .AXI_26_ACLK         (hbm_axi[26].clk    ), //clk
//    .AXI_26_ARESET_N     (hbm_axi[26].arstn  ), //resetn
//    .AXI_26_ARADDR       (hbm_axi[26].araddr ), //read address
//    .AXI_26_ARBURST      (hbm_axi[26].arburst), //read burst type: 01
//    .AXI_26_ARID         (hbm_axi[26].arid   ), //read id
//    .AXI_26_ARLEN        (hbm_axi[26].arlen  ), //read burst size
//    .AXI_26_ARSIZE       (hbm_axi[26].arsize ), //3'b101: 256-bit, 
//    .AXI_26_ARVALID      (hbm_axi[26].arvalid), //read address valid
//    .AXI_26_ARREADY      (hbm_axi[26].arready), //read address ready///////////
//    .AXI_26_RDATA        (hbm_axi[26].rdata  ), //read data
//    .AXI_26_RID          (hbm_axi[26].rid    ), //read data id
//    .AXI_26_RLAST        (hbm_axi[26].rlast  ), //read data last
//    .AXI_26_RRESP        (hbm_axi[26].rresp  ), //read data status
//    .AXI_26_RVALID       (hbm_axi[26].rvalid ), //read data valid
//    .AXI_26_RREADY       (hbm_axi[26].rready ), //read data ready
//    .AXI_26_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_26_AWADDR       (hbm_axi[26].awaddr ), //write address
//    .AXI_26_AWBURST      (hbm_axi[26].awburst), //write burst type
//    .AXI_26_AWID         (hbm_axi[26].awid   ), //write id
//    .AXI_26_AWLEN        (hbm_axi[26].awlen  ), //write burst size
//    .AXI_26_AWSIZE       (hbm_axi[26].awsize ), //write transaction size
//    .AXI_26_AWVALID      (hbm_axi[26].awvalid), //write address valid
//    .AXI_26_AWREADY      (hbm_axi[26].awready), //write address ready//////////
//    .AXI_26_WDATA        (hbm_axi[26].wdata  ), //write data
//    .AXI_26_WLAST        (hbm_axi[26].wlast  ), //write data last
//    .AXI_26_WSTRB        (hbm_axi[26].wstrb  ), //write data strobe
//    .AXI_26_WVALID       (hbm_axi[26].wvalid ), //write valid
//    .AXI_26_WREADY       (hbm_axi[26].wready ), //write data ready
//    .AXI_26_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_26_BID          (hbm_axi[26].bid    ), //write response id
//    .AXI_26_BRESP        (hbm_axi[26].bresp  ), //write response
//    .AXI_26_BVALID       (hbm_axi[26].bvalid ), //write response valid
//    .AXI_26_BREADY       (hbm_axi[26].bready ), //write response ready

//    .AXI_27_ACLK         (hbm_axi[27].clk    ), //clk
//    .AXI_27_ARESET_N     (hbm_axi[27].arstn  ), //resetn
//    .AXI_27_ARADDR       (hbm_axi[27].araddr ), //read address
//    .AXI_27_ARBURST      (hbm_axi[27].arburst), //read burst type: 01
//    .AXI_27_ARID         (hbm_axi[27].arid   ), //read id
//    .AXI_27_ARLEN        (hbm_axi[27].arlen  ), //read burst size
//    .AXI_27_ARSIZE       (hbm_axi[27].arsize ), //3'b101: 256-bit, 
//    .AXI_27_ARVALID      (hbm_axi[27].arvalid), //read address valid
//    .AXI_27_ARREADY      (hbm_axi[27].arready), //read address ready///////////
//    .AXI_27_RDATA        (hbm_axi[27].rdata  ), //read data
//    .AXI_27_RID          (hbm_axi[27].rid    ), //read data id
//    .AXI_27_RLAST        (hbm_axi[27].rlast  ), //read data last
//    .AXI_27_RRESP        (hbm_axi[27].rresp  ), //read data status
//    .AXI_27_RVALID       (hbm_axi[27].rvalid ), //read data valid
//    .AXI_27_RREADY       (hbm_axi[27].rready ), //read data ready
//    .AXI_27_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_27_AWADDR       (hbm_axi[27].awaddr ), //write address
//    .AXI_27_AWBURST      (hbm_axi[27].awburst), //write burst type
//    .AXI_27_AWID         (hbm_axi[27].awid   ), //write id
//    .AXI_27_AWLEN        (hbm_axi[27].awlen  ), //write burst size
//    .AXI_27_AWSIZE       (hbm_axi[27].awsize ), //write transaction size
//    .AXI_27_AWVALID      (hbm_axi[27].awvalid), //write address valid
//    .AXI_27_AWREADY      (hbm_axi[27].awready), //write address ready//////////
//    .AXI_27_WDATA        (hbm_axi[27].wdata  ), //write data
//    .AXI_27_WLAST        (hbm_axi[27].wlast  ), //write data last
//    .AXI_27_WSTRB        (hbm_axi[27].wstrb  ), //write data strobe
//    .AXI_27_WVALID       (hbm_axi[27].wvalid ), //write valid
//    .AXI_27_WREADY       (hbm_axi[27].wready ), //write data ready
//    .AXI_27_WDATA_PARITY (      0            ), //////////////////////////////
//    .AXI_27_BID          (hbm_axi[27].bid    ), //write response id
//    .AXI_27_BRESP        (hbm_axi[27].bresp  ), //write response
//    .AXI_27_BVALID       (hbm_axi[27].bvalid ), //write response valid
//    .AXI_27_BREADY       (hbm_axi[27].bready ), //write response ready

//    .AXI_28_ACLK         (hbm_axi[28].clk    ), //clk
//    .AXI_28_ARESET_N     (hbm_axi[28].arstn  ), //resetn
//    .AXI_28_ARADDR       (hbm_axi[28].araddr ), //read address
//    .AXI_28_ARBURST      (hbm_axi[28].arburst), //read burst type: 01
//    .AXI_28_ARID         (hbm_axi[28].arid   ), //read id
//    .AXI_28_ARLEN        (hbm_axi[28].arlen  ), //read burst size
//    .AXI_28_ARSIZE       (hbm_axi[28].arsize ), //3'b101: 256-bit, 
//    .AXI_28_ARVALID      (hbm_axi[28].arvalid), //read address valid
//    .AXI_28_ARREADY      (hbm_axi[28].arready), //read address ready///////////
//    .AXI_28_RDATA        (hbm_axi[28].rdata  ), //read data
//    .AXI_28_RID          (hbm_axi[28].rid    ), //read data id
//    .AXI_28_RLAST        (hbm_axi[28].rlast  ), //read data last
//    .AXI_28_RRESP        (hbm_axi[28].rresp  ), //read data status
//    .AXI_28_RVALID       (hbm_axi[28].rvalid ), //read data valid
//    .AXI_28_RREADY       (hbm_axi[28].rready ), //read data ready
//    .AXI_28_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_28_AWADDR       (hbm_axi[28].awaddr ), //write address
//    .AXI_28_AWBURST      (hbm_axi[28].awburst), //write burst type
//    .AXI_28_AWID         (hbm_axi[28].awid   ), //write id
//    .AXI_28_AWLEN        (hbm_axi[28].awlen  ), //write burst size
//    .AXI_28_AWSIZE       (hbm_axi[28].awsize ), //write transaction size
//    .AXI_28_AWVALID      (hbm_axi[28].awvalid), //write address valid
//    .AXI_28_AWREADY      (hbm_axi[28].awready), //write address ready//////////
//    .AXI_28_WDATA        (hbm_axi[28].wdata  ), //write data
//    .AXI_28_WLAST        (hbm_axi[28].wlast  ), //write data last
//    .AXI_28_WSTRB        (hbm_axi[28].wstrb  ), //write data strobe
//    .AXI_28_WVALID       (hbm_axi[28].wvalid ), //write valid
//    .AXI_28_WREADY       (hbm_axi[28].wready ), //write data ready
//    .AXI_28_WDATA_PARITY (      0            ), //////////////////////////////
//    .AXI_28_BID          (hbm_axi[28].bid    ), //write response id
//    .AXI_28_BRESP        (hbm_axi[28].bresp  ), //write response
//    .AXI_28_BVALID       (hbm_axi[28].bvalid ), //write response valid
//    .AXI_28_BREADY       (hbm_axi[28].bready ), //write response ready

//    .AXI_29_ACLK         (hbm_axi[29].clk    ), //clk
//    .AXI_29_ARESET_N     (hbm_axi[29].arstn  ), //resetn
//    .AXI_29_ARADDR       (hbm_axi[29].araddr ), //read address
//    .AXI_29_ARBURST      (hbm_axi[29].arburst), //read burst type: 01
//    .AXI_29_ARID         (hbm_axi[29].arid   ), //read id
//    .AXI_29_ARLEN        (hbm_axi[29].arlen  ), //read burst size
//    .AXI_29_ARSIZE       (hbm_axi[29].arsize ), //3'b101: 256-bit, 
//    .AXI_29_ARVALID      (hbm_axi[29].arvalid), //read address valid
//    .AXI_29_ARREADY      (hbm_axi[29].arready), //read address ready///////////
//    .AXI_29_RDATA        (hbm_axi[29].rdata  ), //read data
//    .AXI_29_RID          (hbm_axi[29].rid    ), //read data id
//    .AXI_29_RLAST        (hbm_axi[29].rlast  ), //read data last
//    .AXI_29_RRESP        (hbm_axi[29].rresp  ), //read data status
//    .AXI_29_RVALID       (hbm_axi[29].rvalid ), //read data valid
//    .AXI_29_RREADY       (hbm_axi[29].rready ), //read data ready
//    .AXI_29_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_29_AWADDR       (hbm_axi[29].awaddr ), //write address
//    .AXI_29_AWBURST      (hbm_axi[29].awburst), //write burst type
//    .AXI_29_AWID         (hbm_axi[29].awid   ), //write id
//    .AXI_29_AWLEN        (hbm_axi[29].awlen  ), //write burst size
//    .AXI_29_AWSIZE       (hbm_axi[29].awsize ), //write transaction size
//    .AXI_29_AWVALID      (hbm_axi[29].awvalid), //write address valid
//    .AXI_29_AWREADY      (hbm_axi[29].awready), //write address ready//////////
//    .AXI_29_WDATA        (hbm_axi[29].wdata  ), //write data
//    .AXI_29_WLAST        (hbm_axi[29].wlast  ), //write data last
//    .AXI_29_WSTRB        (hbm_axi[29].wstrb  ), //write data strobe
//    .AXI_29_WVALID       (hbm_axi[29].wvalid ), //write valid
//    .AXI_29_WREADY       (hbm_axi[29].wready ), //write data ready
//    .AXI_29_WDATA_PARITY (    0              ), //////////////////////////////
//    .AXI_29_BID          (hbm_axi[29].bid    ), //write response id
//    .AXI_29_BRESP        (hbm_axi[29].bresp  ), //write response
//    .AXI_29_BVALID       (hbm_axi[29].bvalid ), //write response valid
//    .AXI_29_BREADY       (hbm_axi[29].bready ), //write response ready

//    .AXI_30_ACLK         (hbm_axi[30].clk    ), //clk
//    .AXI_30_ARESET_N     (hbm_axi[30].arstn  ), //resetn
//    .AXI_30_ARADDR       (hbm_axi[30].araddr ), //read address
//    .AXI_30_ARBURST      (hbm_axi[30].arburst), //read burst type: 01
//    .AXI_30_ARID         (hbm_axi[30].arid   ), //read id
//    .AXI_30_ARLEN        (hbm_axi[30].arlen  ), //read burst size
//    .AXI_30_ARSIZE       (hbm_axi[30].arsize ), //3'b101: 256-bit, 
//    .AXI_30_ARVALID      (hbm_axi[30].arvalid), //read address valid
//    .AXI_30_ARREADY      (hbm_axi[30].arready), //read address ready///////////
//    .AXI_30_RDATA        (hbm_axi[30].rdata  ), //read data
//    .AXI_30_RID          (hbm_axi[30].rid    ), //read data id
//    .AXI_30_RLAST        (hbm_axi[30].rlast  ), //read data last
//    .AXI_30_RRESP        (hbm_axi[30].rresp  ), //read data status
//    .AXI_30_RVALID       (hbm_axi[30].rvalid ), //read data valid
//    .AXI_30_RREADY       (hbm_axi[30].rready ), //read data ready
//    .AXI_30_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_30_AWADDR       (hbm_axi[30].awaddr ), //write address
//    .AXI_30_AWBURST      (hbm_axi[30].awburst), //write burst type
//    .AXI_30_AWID         (hbm_axi[30].awid   ), //write id
//    .AXI_30_AWLEN        (hbm_axi[30].awlen  ), //write burst size
//    .AXI_30_AWSIZE       (hbm_axi[30].awsize ), //write transaction size
//    .AXI_30_AWVALID      (hbm_axi[30].awvalid), //write address valid
//    .AXI_30_AWREADY      (hbm_axi[30].awready), //write address ready//////////
//    .AXI_30_WDATA        (hbm_axi[30].wdata  ), //write data
//    .AXI_30_WLAST        (hbm_axi[30].wlast  ), //write data last
//    .AXI_30_WSTRB        (hbm_axi[30].wstrb  ), //write data strobe
//    .AXI_30_WVALID       (hbm_axi[30].wvalid ), //write valid
//    .AXI_30_WREADY       (hbm_axi[30].wready ), //write data ready
//    .AXI_30_WDATA_PARITY (     0             ), //////////////////////////////
//    .AXI_30_BID          (hbm_axi[30].bid    ), //write response id
//    .AXI_30_BRESP        (hbm_axi[30].bresp  ), //write response
//    .AXI_30_BVALID       (hbm_axi[30].bvalid ), //write response valid
//    .AXI_30_BREADY       (hbm_axi[30].bready ), //write response ready

//    .AXI_31_ACLK         (hbm_axi[31].clk    ), //clk
//    .AXI_31_ARESET_N     (hbm_axi[31].arstn  ), //resetn
//    .AXI_31_ARADDR       (hbm_axi[31].araddr ), //read address
//    .AXI_31_ARBURST      (hbm_axi[31].arburst), //read burst type: 01
//    .AXI_31_ARID         (hbm_axi[31].arid   ), //read id
//    .AXI_31_ARLEN        (hbm_axi[31].arlen  ), //read burst size
//    .AXI_31_ARSIZE       (hbm_axi[31].arsize ), //3'b101: 256-bit, 
//    .AXI_31_ARVALID      (hbm_axi[31].arvalid), //read address valid
//    .AXI_31_ARREADY      (hbm_axi[31].arready), //read address ready///////////
//    .AXI_31_RDATA        (hbm_axi[31].rdata  ), //read data
//    .AXI_31_RID          (hbm_axi[31].rid    ), //read data id
//    .AXI_31_RLAST        (hbm_axi[31].rlast  ), //read data last
//    .AXI_31_RRESP        (hbm_axi[31].rresp  ), //read data status
//    .AXI_31_RVALID       (hbm_axi[31].rvalid ), //read data valid
//    .AXI_31_RREADY       (hbm_axi[31].rready ), //read data ready
//    .AXI_31_RDATA_PARITY (                   ), //read data parity/////////////
//    .AXI_31_AWADDR       (hbm_axi[31].awaddr ), //write address
//    .AXI_31_AWBURST      (hbm_axi[31].awburst), //write burst type
//    .AXI_31_AWID         (hbm_axi[31].awid   ), //write id
//    .AXI_31_AWLEN        (hbm_axi[31].awlen  ), //write burst size
//    .AXI_31_AWSIZE       (hbm_axi[31].awsize ), //write transaction size
//    .AXI_31_AWVALID      (hbm_axi[31].awvalid), //write address valid
//    .AXI_31_AWREADY      (hbm_axi[31].awready), //write address ready//////////
//    .AXI_31_WDATA        (hbm_axi[31].wdata  ), //write data
//    .AXI_31_WLAST        (hbm_axi[31].wlast  ), //write data last
//    .AXI_31_WSTRB        (hbm_axi[31].wstrb  ), //write data strobe
//    .AXI_31_WVALID       (hbm_axi[31].wvalid ), //write valid
//    .AXI_31_WREADY       (hbm_axi[31].wready ), //write data ready
//    .AXI_31_WDATA_PARITY (    0              ), //////////////////////////////
//    .AXI_31_BID          (hbm_axi[31].bid    ), //write response id
//    .AXI_31_BRESP        (hbm_axi[31].bresp  ), //write response
//    .AXI_31_BVALID       (hbm_axi[31].bvalid ), //write response valid
//    .AXI_31_BREADY       (hbm_axi[31].bready ), //write response ready

//    .APB_0_PWDATA   (0),
//    .APB_0_PADDR    (0),
//    .APB_0_PCLK     (APB_0_PCLK_BUF),
//    .APB_0_PENABLE  (0),
//    .APB_0_PRESET_N (APB_0_PRESET_N),
//    .APB_0_PSEL     (0),
//    .APB_0_PWRITE   (0),
//    .APB_0_PRDATA       (),
//    .APB_0_PREADY       (),
//    .APB_0_PSLVERR      (),
//    .DRAM_0_STAT_CATTRIP(),
//    .DRAM_0_STAT_TEMP   (),
//    .apb_complete_0     (),

//    .APB_1_PWDATA   (0),
//    .APB_1_PADDR    (0),
//    .APB_1_PCLK     (APB_1_PCLK_BUF),
//    .APB_1_PENABLE  (0),
//    .APB_1_PRESET_N (APB_1_PRESET_N),
//    .APB_1_PSEL     (0),
//    .APB_1_PWRITE   (0),
//    .APB_1_PRDATA       (),
//    .APB_1_PREADY       (),
//    .APB_1_PSLVERR      (),
//    .DRAM_1_STAT_CATTRIP(),
//    .DRAM_1_STAT_TEMP   (),     
//    .apb_complete_1     ()
//);

////////////////////////////////////////////pcie///////////////

   
   // Local Parameters derived from user selection
   localparam integer 				   USER_CLK_FREQ         = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? 5 : 4);
   localparam TCQ = 1;
   localparam C_S_AXI_ID_WIDTH = 4; 
   localparam C_M_AXI_ID_WIDTH = 4; 
   localparam C_S_AXI_DATA_WIDTH = C_DATA_WIDTH;
   localparam C_M_AXI_DATA_WIDTH = C_DATA_WIDTH;
   localparam C_S_AXI_ADDR_WIDTH = 64;
   localparam C_M_AXI_ADDR_WIDTH = 64;
   localparam C_NUM_USR_IRQ	 = 1;
   
   wire 					   user_lnk_up;
   
   //----------------------------------------------------------------------------------------------------------------//
   //  AXI Interface                                                                                                 //
   //----------------------------------------------------------------------------------------------------------------//
   
   wire 					   user_clk;
   wire 					   user_resetn;
   
  // Wires for Avery HOT/WARM and COLD RESET
   wire 					   avy_sys_rst_n_c;
   wire 					   avy_cfg_hot_reset_out;
   reg 						   avy_sys_rst_n_g;
   reg 						   avy_cfg_hot_reset_out_g;
   assign avy_sys_rst_n_c = avy_sys_rst_n_g;
   assign avy_cfg_hot_reset_out = avy_cfg_hot_reset_out_g;
   initial begin 
      avy_sys_rst_n_g = 1;
      avy_cfg_hot_reset_out_g =0;
   end
   


  //----------------------------------------------------------------------------------------------------------------//
  //    System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

    wire                                    sys_clk;
    wire                                    sys_clk_gt;
    wire                                    sys_rst_n_c;

  // User Clock LED Heartbeat
     reg [25:0] 			     user_clk_heartbeat;
     reg [((2*C_NUM_USR_IRQ)-1):0]		usr_irq_function_number=0;
     reg [C_NUM_USR_IRQ-1:0] 		     usr_irq_req = 0;
     wire [C_NUM_USR_IRQ-1:0] 		     usr_irq_ack;

      //-- AXI Master Write Address Channel
     wire [C_M_AXI_ADDR_WIDTH-1:0] m_axi_awaddr;
     wire [C_M_AXI_ID_WIDTH-1:0] m_axi_awid;
     wire [2:0] 		 m_axi_awprot;
     wire [1:0] 		 m_axi_awburst;
     wire [2:0] 		 m_axi_awsize;
     wire [3:0] 		 m_axi_awcache;
     wire [7:0] 		 m_axi_awlen;
     wire 			 m_axi_awlock;
     wire 			 m_axi_awvalid;
     wire 			 m_axi_awready;

     //-- AXI Master Write Data Channel
     wire [C_M_AXI_DATA_WIDTH-1:0]     m_axi_wdata;
     wire [(C_M_AXI_DATA_WIDTH/8)-1:0] m_axi_wstrb;
     wire 			       m_axi_wlast;
     wire 			       m_axi_wvalid;
     wire 			       m_axi_wready;
     //-- AXI Master Write Response Channel
     wire 			       m_axi_bvalid;
     wire 			       m_axi_bready;
     wire [C_M_AXI_ID_WIDTH-1 : 0]     m_axi_bid ;
     wire [1:0]                        m_axi_bresp ;

     //-- AXI Master Read Address Channel
     wire [C_M_AXI_ID_WIDTH-1 : 0]     m_axi_arid;
     wire [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_araddr;
     wire [7:0]                        m_axi_arlen;
     wire [2:0]                        m_axi_arsize;
     wire [1:0]                        m_axi_arburst;
     wire [2:0] 		       m_axi_arprot;
     wire 			       m_axi_arvalid;
     wire 			       m_axi_arready;
     wire 			       m_axi_arlock;
     wire [3:0] 		       m_axi_arcache;

     //-- AXI Master Read Data Channel
     wire [C_M_AXI_ID_WIDTH-1 : 0]   m_axi_rid;
     wire [C_M_AXI_DATA_WIDTH-1:0]   m_axi_rdata;
     wire [1:0] 		     m_axi_rresp;
     wire 			     m_axi_rvalid;
     wire 			     m_axi_rready;

///////////////////////////////////////////////////////////////////////////////
// CQ forwarding port to BARAM

      wire [C_M_AXI_ADDR_WIDTH-1:0] m_axib_awaddr;
      wire [C_M_AXI_ID_WIDTH-1:0]   m_axib_awid;
      wire [2:0] 		    m_axib_awprot;
      wire [1:0] 		    m_axib_awburst;
      wire [2:0] 		    m_axib_awsize;
      wire [3:0] 		    m_axib_awcache;
      wire [7:0] 		    m_axib_awlen;
      wire 			    m_axib_awlock;
      wire 			    m_axib_awvalid;
      wire 			    m_axib_awready;
      //-- AXI Master Write Data Channel
      wire [C_M_AXI_DATA_WIDTH-1:0] m_axib_wdata;
      wire [(C_M_AXI_DATA_WIDTH/8)-1:0] m_axib_wstrb;
      wire 			     m_axib_wlast;
      wire 			     m_axib_wvalid;
      wire 			     m_axib_wready;
      //-- AXI Master Write Response Channel
      wire 			     m_axib_bvalid;
      wire 			     m_axib_bready;
      wire [C_M_AXI_ID_WIDTH-1 : 0] m_axib_bid ;
      wire [1 : 0]                  m_axib_bresp ;

      //-- AXI Master Read Address Channel
      wire [C_M_AXI_ID_WIDTH-1 : 0] m_axib_arid;
      wire [C_M_AXI_ADDR_WIDTH-1:0] m_axib_araddr;
      wire [7 : 0]                  m_axib_arlen;
      wire [2 : 0]                  m_axib_arsize;
      wire [1 : 0]                  m_axib_arburst;
      wire [2:0] 		    m_axib_arprot;
      wire 			    m_axib_arvalid;
      wire 			    m_axib_arready;
      wire 			    m_axib_arlock;
      wire [3:0] 		    m_axib_arcache;
////////////////////////////////////////////////////////////////////////////////
   //-- AXI Master Read Data Channel
    wire [C_M_AXI_ID_WIDTH-1 : 0]       m_axib_rid;
    wire [C_M_AXI_DATA_WIDTH-1:0]       m_axib_rdata;
    wire [1:0] 		                m_axib_rresp;
    wire 			        m_axib_rvalid;
    wire 			        m_axib_rready;




//////////////////////////////////////////////////  LITE
   //-- AXI Master Write Address Channel
    wire [31:0] m_axil_awaddr;
    wire [2:0]  m_axil_awprot;
    wire 	m_axil_awvalid;
    wire 	m_axil_awready;

    //-- AXI Master Write Data Channel
    wire [31:0] m_axil_wdata;
    wire [3:0]  m_axil_wstrb;
    wire 	m_axil_wvalid;
    wire 	m_axil_wready;
    //-- AXI Master Write Response Channel
    wire 	m_axil_bvalid;
    wire 	m_axil_bready;
    //-- AXI Master Read Address Channel
    wire [31:0] m_axil_araddr;
    wire [2:0]  m_axil_arprot;
    wire 	m_axil_arvalid;
    wire 	m_axil_arready;
    //-- AXI Master Read Data Channel
    wire [31:0] m_axil_rdata;
    wire [1:0]  m_axil_rresp;
    wire 	m_axil_rvalid;
    wire 	m_axil_rready;
    wire [1:0]  m_axil_bresp;

    wire [2:0]    msi_vector_width;
    wire          msi_enable;
    wire [3:0]                  leds;

 wire free_run_clock;
    
  wire [5:0]                          cfg_ltssm_state;

  // Ref clock buffer
  IBUFDS_GTE4 # (.REFCLK_HROW_CK_SEL(2'b00)) refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
  // Reset buffer
  IBUF   sys_reset_n_ibuf (.O(sys_rst_n_c), .I(sys_rst_n));



  // Core Top Level Wrapper
  xdma_0 xdma_0_i 
     (
      //---------------------------------------------------------------------------------------//
      //  PCI Express (pci_exp) Interface                                                      //
      //---------------------------------------------------------------------------------------//
      .sys_rst_n       ( sys_rst_n_c ),
      .sys_clk         ( sys_clk ),
      .sys_clk_gt      ( sys_clk_gt),
      
      // Tx
      .pci_exp_txn     ( pci_exp_txn ),
      .pci_exp_txp     ( pci_exp_txp ),
      
      // Rx
      .pci_exp_rxn     ( pci_exp_rxn ),
      .pci_exp_rxp     ( pci_exp_rxp ),


       // AXI MM Interface
      .m_axi_awid      (m_axi_awid  ),
      .m_axi_awaddr    (m_axi_awaddr),
      .m_axi_awlen     (m_axi_awlen),
      .m_axi_awsize    (m_axi_awsize),
      .m_axi_awburst   (m_axi_awburst),
      .m_axi_awprot    (m_axi_awprot),
      .m_axi_awvalid   (m_axi_awvalid),
      .m_axi_awready   (m_axi_awready),
      .m_axi_awlock    (m_axi_awlock),
      .m_axi_awcache   (m_axi_awcache),
      .m_axi_wdata     (m_axi_wdata),
      .m_axi_wstrb     (m_axi_wstrb),
      .m_axi_wlast     (m_axi_wlast),
      .m_axi_wvalid    (m_axi_wvalid),
      .m_axi_wready    (m_axi_wready),
      .m_axi_bid       (m_axi_bid),
      .m_axi_bresp     (m_axi_bresp),
      .m_axi_bvalid    (m_axi_bvalid),
      .m_axi_bready    (m_axi_bready),
      .m_axi_arid      (m_axi_arid),
      .m_axi_araddr    (m_axi_araddr),
      .m_axi_arlen     (m_axi_arlen),
      .m_axi_arsize    (m_axi_arsize),
      .m_axi_arburst   (m_axi_arburst),
      .m_axi_arprot    (m_axi_arprot),
      .m_axi_arvalid   (m_axi_arvalid),
      .m_axi_arready   (m_axi_arready),
      .m_axi_arlock    (m_axi_arlock),
      .m_axi_arcache   (m_axi_arcache),
      .m_axi_rid       (m_axi_rid),
      .m_axi_rdata     (m_axi_rdata),
      .m_axi_rresp     (m_axi_rresp),
      .m_axi_rlast     (m_axi_rlast),
      .m_axi_rvalid    (m_axi_rvalid),
      .m_axi_rready    (m_axi_rready),
       // CQ Bypass ports
      .m_axib_awid      (m_axib_awid),
      .m_axib_awaddr    (m_axib_awaddr),
      .m_axib_awlen     (m_axib_awlen),
      .m_axib_awsize    (m_axib_awsize),
      .m_axib_awburst   (m_axib_awburst),
      .m_axib_awprot    (m_axib_awprot),
      .m_axib_awvalid   (m_axib_awvalid),
      .m_axib_awready   (m_axib_awready),
      .m_axib_awlock    (m_axib_awlock),
      .m_axib_awcache   (m_axib_awcache),
      .m_axib_wdata     (m_axib_wdata),
      .m_axib_wstrb     (m_axib_wstrb),
      .m_axib_wlast     (m_axib_wlast),
      .m_axib_wvalid    (m_axib_wvalid),
      .m_axib_wready    (m_axib_wready),
      .m_axib_bid       (m_axib_bid),
      .m_axib_bresp     (m_axib_bresp),
      .m_axib_bvalid    (m_axib_bvalid),
      .m_axib_bready    (m_axib_bready),
      .m_axib_arid      (m_axib_arid),
      .m_axib_araddr    (m_axib_araddr),
      .m_axib_arlen     (m_axib_arlen),
      .m_axib_arsize    (m_axib_arsize),
      .m_axib_arburst   (m_axib_arburst),
      .m_axib_arprot    (m_axib_arprot),
      .m_axib_arvalid   (m_axib_arvalid),
      .m_axib_arready   (m_axib_arready),
      .m_axib_arlock    (m_axib_arlock),
      .m_axib_arcache   (m_axib_arcache),
      .m_axib_rid       (m_axib_rid),
      .m_axib_rdata     (m_axib_rdata),
      .m_axib_rresp     (m_axib_rresp),
      .m_axib_rlast     (m_axib_rlast),
      .m_axib_rvalid    (m_axib_rvalid),
      .m_axib_rready    (m_axib_rready),
      // LITE interface   
      //-- AXI Master Write Address Channel
      .m_axil_awaddr    (m_axil_awaddr),
      .m_axil_awprot    (m_axil_awprot),
      .m_axil_awvalid   (m_axil_awvalid),
      .m_axil_awready   (m_axil_awready),
      //-- AXI Master Write Data Channel
      .m_axil_wdata     (m_axil_wdata),
      .m_axil_wstrb     (m_axil_wstrb),
      .m_axil_wvalid    (m_axil_wvalid),
      .m_axil_wready    (m_axil_wready),
      //-- AXI Master Write Response Channel
      .m_axil_bvalid    (m_axil_bvalid),
      .m_axil_bresp     (m_axil_bresp),
      .m_axil_bready    (m_axil_bready),
      //-- AXI Master Read Address Channel
      .m_axil_araddr    (m_axil_araddr),
      .m_axil_arprot    (m_axil_arprot),
      .m_axil_arvalid   (m_axil_arvalid),
      .m_axil_arready   (m_axil_arready),
      .m_axil_rdata     (m_axil_rdata),
      //-- AXI Master Read Data Channel
      .m_axil_rresp     (m_axil_rresp),
      .m_axil_rvalid    (m_axil_rvalid),
      .m_axil_rready    (m_axil_rready),




      .usr_irq_req       (usr_irq_req),
      .usr_irq_ack       (usr_irq_ack),
      .msi_enable        (msi_enable),
      .msi_vector_width  (msi_vector_width),


     // Config managemnet interface
      .cfg_mgmt_addr  ( 19'b0 ),
      .cfg_mgmt_write ( 1'b0 ),
      .cfg_mgmt_write_data ( 32'b0 ),
      .cfg_mgmt_byte_enable ( 4'b0 ),
      .cfg_mgmt_read  ( 1'b0 ),
      .cfg_mgmt_read_data (),
      .cfg_mgmt_read_write_done (),






      //-- AXI Global
      .axi_aclk        ( user_clk ),
      .axi_aresetn     ( user_resetn ),
  





      .user_lnk_up     ( user_lnk_up )
    );


  // XDMA taget application
  xdma_app #(
    .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
    .N_MEM_INTF(N_MEM_INTF)
  ) xdma_app_i (

      // AXI Lite Master Interface connections
      .s_axil_awaddr  (m_axil_awaddr[31:0]),
      .s_axil_awvalid (m_axil_awvalid),
      .s_axil_awready (m_axil_awready),
      .s_axil_wdata   (m_axil_wdata[31:0]),    // block fifo for AXI lite only 31 bits.
      .s_axil_wstrb   (m_axil_wstrb[3:0]),
      .s_axil_wvalid  (m_axil_wvalid),
      .s_axil_wready  (m_axil_wready),
      .s_axil_bresp   (m_axil_bresp),
      .s_axil_bvalid  (m_axil_bvalid),
      .s_axil_bready  (m_axil_bready),
      .s_axil_araddr  (m_axil_araddr[31:0]),
      .s_axil_arvalid (m_axil_arvalid),
      .s_axil_arready (m_axil_arready),
      .s_axil_rdata   (m_axil_rdata),   // block ram for AXI Lite is only 31 bits
      .s_axil_rresp   (m_axil_rresp),
      .s_axil_rvalid  (m_axil_rvalid),
      .s_axil_rready  (m_axil_rready),



      // AXI Memory Mapped interface
      .s_axi_awid      (m_axi_awid),
      .s_axi_awaddr    (m_axi_awaddr),
      .s_axi_awlen     (m_axi_awlen),
      .s_axi_awsize    (m_axi_awsize),
      .s_axi_awburst   (m_axi_awburst),
      .s_axi_awvalid   (m_axi_awvalid),
      .s_axi_awready   (m_axi_awready),
      .s_axi_wdata     (m_axi_wdata),
      .s_axi_wstrb     (m_axi_wstrb),
      .s_axi_wlast     (m_axi_wlast),
      .s_axi_wvalid    (m_axi_wvalid),
      .s_axi_wready    (m_axi_wready),
      .s_axi_bid       (m_axi_bid),
      .s_axi_bresp     (m_axi_bresp),
      .s_axi_bvalid    (m_axi_bvalid),
      .s_axi_bready    (m_axi_bready),
      .s_axi_arid      (m_axi_arid),
      .s_axi_araddr    (m_axi_araddr),
      .s_axi_arlen     (m_axi_arlen),
      .s_axi_arsize    (m_axi_arsize),
      .s_axi_arburst   (m_axi_arburst),
      .s_axi_arvalid   (m_axi_arvalid),
      .s_axi_arready   (m_axi_arready),
      .s_axi_rid       (m_axi_rid),
      .s_axi_rdata     (m_axi_rdata),
      .s_axi_rresp     (m_axi_rresp),
      .s_axi_rlast     (m_axi_rlast),
      .s_axi_rvalid    (m_axi_rvalid),
      .s_axi_rready    (m_axi_rready),

      // AXI stream interface for the CQ forwarding
      .s_axib_awid      (m_axib_awid),
      .s_axib_awaddr    (m_axib_awaddr[18:0]),
      .s_axib_awlen     (m_axib_awlen),
      .s_axib_awsize    (m_axib_awsize),
      .s_axib_awburst   (m_axib_awburst),
      .s_axib_awvalid   (m_axib_awvalid),
      .s_axib_awready   (m_axib_awready),
      .s_axib_wdata     (m_axib_wdata),
      .s_axib_wstrb     (m_axib_wstrb),
      .s_axib_wlast     (m_axib_wlast),
      .s_axib_wvalid    (m_axib_wvalid),
      .s_axib_wready    (m_axib_wready),
      .s_axib_bid       (m_axib_bid),
      .s_axib_bresp     (m_axib_bresp),
      .s_axib_bvalid    (m_axib_bvalid),
      .s_axib_bready    (m_axib_bready),
      .s_axib_arid      (m_axib_arid),
      .s_axib_araddr    (m_axib_araddr[18:0]),
      .s_axib_arlen     (m_axib_arlen),
      .s_axib_arsize    (m_axib_arsize),
      .s_axib_arburst   (m_axib_arburst),
      .s_axib_arvalid   (m_axib_arvalid),
      .s_axib_arready   (m_axib_arready),
      .s_axib_rid       (m_axib_rid),
      .s_axib_rdata     (m_axib_rdata),
      .s_axib_rresp     (m_axib_rresp),
      .s_axib_rlast     (m_axib_rlast),
      .s_axib_rvalid    (m_axib_rvalid),
      .s_axib_rready    (m_axib_rready),


      .user_clk(user_clk),
      .user_resetn(user_resetn),
      .user_lnk_up(user_lnk_up),
      .sys_rst_n(sys_rst_n_c),

      .leds(),

  ///////////hbm——test——reg
    .hbm_axi_clk        (hbm_axi_clk),
    .hbm_reset          (hbm_reset),
    .work_group_size    (work_group_size),
    .stride             (stride),
    .num_mem_ops        (num_mem_ops),
    .mem_burst_size     (mem_burst_size),
    .initial_addr       (initial_addr),
    .hbm_channel        (hbm_channel),
    .write_enable       (write_enable),
    .read_enable        (read_enable),
    .latency_test_enable(latency_test_enable),
    .start              (start),
    .end_wr             (end_wr_o),
    .end_rd             (end_rd_o),
    .lat_timer_sum_wr   (lat_timer_sum_wr_o),
    .lat_timer_sum_rd   (lat_timer_sum_rd_o),
    .lat_timer_valid    (lat_timer_valid),
    .lat_timer          (lat_timer)    
  );




//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////            ddr
////////////////////////////////////////////////////////////////////////////////////////////


  
  wire                  c0_ddr4_clk;
  wire                  c0_ddr4_rst;


  reg                              c0_ddr4_aresetn;

//  // Slave Interface Write Address Ports
//  wire [3:0]                        c0_ddr4_s_axi_awid;
//  wire [33:0]                       c0_ddr4_s_axi_awaddr;
//  wire [7:0]                        c0_ddr4_s_axi_awlen;
//  wire [2:0]                        c0_ddr4_s_axi_awsize;
//  wire [1:0]                        c0_ddr4_s_axi_awburst;
//  wire [3:0]                        c0_ddr4_s_axi_awcache;
//  wire [2:0]                        c0_ddr4_s_axi_awprot;
//  wire                              c0_ddr4_s_axi_awvalid;
//  wire                              c0_ddr4_s_axi_awready;
//   // Slave Interface Write Data Ports
//  wire [511:0]                      c0_ddr4_s_axi_wdata;
//  wire [63:0]                       c0_ddr4_s_axi_wstrb;
//  wire                              c0_ddr4_s_axi_wlast;
//  wire                              c0_ddr4_s_axi_wvalid;
//  wire                              c0_ddr4_s_axi_wready;
//   // Slave Interface Write Response Ports
//  wire                              c0_ddr4_s_axi_bready;
//  wire [3:0]                        c0_ddr4_s_axi_bid;
//  wire [1:0]                        c0_ddr4_s_axi_bresp;
//  wire                              c0_ddr4_s_axi_bvalid;
//   // Slave Interface Read Address Ports
//  wire [3:0]                        c0_ddr4_s_axi_arid;
//  wire [33:0]                       c0_ddr4_s_axi_araddr;
//  wire [7:0]                        c0_ddr4_s_axi_arlen;
//  wire [2:0]                        c0_ddr4_s_axi_arsize;
//  wire [1:0]                        c0_ddr4_s_axi_arburst;
//  wire [3:0]                        c0_ddr4_s_axi_arcache;
//  wire                              c0_ddr4_s_axi_arvalid;
//  wire                              c0_ddr4_s_axi_arready;
//   // Slave Interface Read Data Ports
//  wire                              c0_ddr4_s_axi_rready;
//  wire [3:0]                        c0_ddr4_s_axi_rid;
//  wire [511:0]                      c0_ddr4_s_axi_rdata;
//  wire [1:0]                        c0_ddr4_s_axi_rresp;
//  wire                              c0_ddr4_s_axi_rlast;
//  wire                              c0_ddr4_s_axi_rvalid;



  wire                  c1_ddr4_clk;
  wire                  c1_ddr4_rst;


  reg                              c1_ddr4_aresetn;

  // Slave Interface Write Address Ports
  wire [3:0]                        c1_ddr4_s_axi_awid;
  wire [33:0]                       c1_ddr4_s_axi_awaddr;
  wire [7:0]                        c1_ddr4_s_axi_awlen;
  wire [2:0]                        c1_ddr4_s_axi_awsize;
  wire [1:0]                        c1_ddr4_s_axi_awburst;
  wire [3:0]                        c1_ddr4_s_axi_awcache;
  wire [2:0]                        c1_ddr4_s_axi_awprot;
  wire                              c1_ddr4_s_axi_awvalid;
  wire                              c1_ddr4_s_axi_awready;
   // Slave Interface Write Data Ports
  wire [511:0]                      c1_ddr4_s_axi_wdata;
  wire [63:0]                       c1_ddr4_s_axi_wstrb;
  wire                              c1_ddr4_s_axi_wlast;
  wire                              c1_ddr4_s_axi_wvalid;
  wire                              c1_ddr4_s_axi_wready;
   // Slave Interface Write Response Ports
  wire                              c1_ddr4_s_axi_bready;
  wire [3:0]                        c1_ddr4_s_axi_bid;
  wire [1:0]                        c1_ddr4_s_axi_bresp;
  wire                              c1_ddr4_s_axi_bvalid;
   // Slave Interface Read Address Ports
  wire [3:0]                        c1_ddr4_s_axi_arid;
  wire [33:0]                       c1_ddr4_s_axi_araddr;
  wire [7:0]                        c1_ddr4_s_axi_arlen;
  wire [2:0]                        c1_ddr4_s_axi_arsize;
  wire [1:0]                        c1_ddr4_s_axi_arburst;
  wire [3:0]                        c1_ddr4_s_axi_arcache;
  wire                              c1_ddr4_s_axi_arvalid;
  wire                              c1_ddr4_s_axi_arready;
   // Slave Interface Read Data Ports
  wire                              c1_ddr4_s_axi_rready;
  wire [3:0]                        c1_ddr4_s_axi_rid;
  wire [511:0]                      c1_ddr4_s_axi_rdata;
  wire [1:0]                        c1_ddr4_s_axi_rresp;
  wire                              c1_ddr4_s_axi_rlast;
  wire                              c1_ddr4_s_axi_rvalid;

                                              
                                              
   always @(posedge c0_ddr4_clk) begin      
     c0_ddr4_aresetn <= ~c0_ddr4_rst;       
   end                                      
                                              
                                              
   always @(posedge c1_ddr4_clk) begin      
     c1_ddr4_aresetn <= ~c1_ddr4_rst;       
   end                                      




                                              
 
 
//  assign    c0_ddr4_s_axi_awid               = 0;       
//  assign    c0_ddr4_s_axi_awaddr             = 0;
//  assign    c0_ddr4_s_axi_awlen              = 0; 
//  assign    c0_ddr4_s_axi_awsize             = 0;
//  assign    c0_ddr4_s_axi_awburst            = 0;
//  assign    c0_ddr4_s_axi_awlock             = 0;
//  assign    c0_ddr4_s_axi_awcache            = 0;
//  assign    c0_ddr4_s_axi_awprot             = 0;
//  assign    c0_ddr4_s_axi_awqos              = 0; 
//  assign    c0_ddr4_s_axi_awvalid            = 0;
//  assign    c0_ddr4_s_axi_wdata              = 0; 
//  assign    c0_ddr4_s_axi_wstrb              = 0; 
//  assign    c0_ddr4_s_axi_wlast              = 0; 
//  assign    c0_ddr4_s_axi_wvalid             = 0;
//  assign    c0_ddr4_s_axi_bready             = 0;
//  assign    c0_ddr4_s_axi_arid               = 0;  
//  assign    c0_ddr4_s_axi_araddr             = 0;
//  assign    c0_ddr4_s_axi_arlen              = 0;
//  assign    c0_ddr4_s_axi_arsize             = 0;
//  assign    c0_ddr4_s_axi_arburst            = 0;
//  assign    c0_ddr4_s_axi_arlock             = 0;
//  assign    c0_ddr4_s_axi_arcache            = 0;
//  assign    c0_ddr4_s_axi_arprot             = 0;
//  assign    c0_ddr4_s_axi_arqos              = 0; 
//  assign    c0_ddr4_s_axi_arvalid            = 0;
//  assign    c0_ddr4_s_axi_rready             = 0;

//  assign    c1_ddr4_s_axi_awid               = 0;       
//  assign    c1_ddr4_s_axi_awaddr             = 0;
//  assign    c1_ddr4_s_axi_awlen              = 0; 
//  assign    c1_ddr4_s_axi_awsize             = 0;
//  assign    c1_ddr4_s_axi_awburst            = 0;
//  assign    c1_ddr4_s_axi_awlock             = 0;
//  assign    c1_ddr4_s_axi_awcache            = 0;
//  assign    c1_ddr4_s_axi_awprot             = 0;
//  assign    c1_ddr4_s_axi_awqos              = 0; 
//  assign    c1_ddr4_s_axi_awvalid            = 0;
//  assign    c1_ddr4_s_axi_wdata              = 0; 
//  assign    c1_ddr4_s_axi_wstrb              = 0; 
//  assign    c1_ddr4_s_axi_wlast              = 0; 
//  assign    c1_ddr4_s_axi_wvalid             = 0;
//  assign    c1_ddr4_s_axi_bready             = 0;
//  assign    c1_ddr4_s_axi_arid               = 0;  
//  assign    c1_ddr4_s_axi_araddr             = 0;
//  assign    c1_ddr4_s_axi_arlen              = 0;
//  assign    c1_ddr4_s_axi_arsize             = 0;
//  assign    c1_ddr4_s_axi_arburst            = 0;
//  assign    c1_ddr4_s_axi_arlock             = 0;
//  assign    c1_ddr4_s_axi_arcache            = 0;
//  assign    c1_ddr4_s_axi_arprot             = 0;
//  assign    c1_ddr4_s_axi_arqos              = 0; 
//  assign    c1_ddr4_s_axi_arvalid            = 0;
//  assign    c1_ddr4_s_axi_rready             = 0;

 
    IBUFDS #(
      .IBUF_LOW_PWR("TRUE")     // Low power="TRUE", Highest performance="FALSE" 
   ) IBUFDS0_inst (
      .O(ddr0_sys_100M),  // Buffer output
      .I(ddr0_sys_100M_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(ddr0_sys_100M_n) // Diff_n buffer input (connect directly to top-level port)
   );
 
   
     BUFG BUFG0_inst (
      .O(DDR0_sys_clk), // 1-bit output: Clock output
      .I(ddr0_sys_100M)  // 1-bit input: Clock input
   ); 
 
 
    IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS1_inst (
      .O(ddr1_sys_100M),  // Buffer output
      .I(ddr1_sys_100M_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(ddr1_sys_100M_n) // Diff_n buffer input (connect directly to top-level port)
   );
 
   
     BUFG BUFG1_inst (
      .O(DDR1_sys_clk), // 1-bit output: Clock output
      .I(ddr1_sys_100M)  // 1-bit input: Clock input
   );


       assign hbm_axi[0].clk   = c0_ddr4_clk;
       assign hbm_axi[1].clk   = c1_ddr4_clk;
       assign hbm_axi[0].arstn = c0_ddr4_aresetn & (~hbm_reset);
       assign hbm_axi[1].arstn = c1_ddr4_aresetn & (~hbm_reset);
   
   
ddr4_0 u_ddr4_0
  (
   .sys_rst           (1'b0),

   .c0_sys_clk_i                   (DDR0_sys_clk),
   .c0_init_calib_complete (),
   .c0_ddr4_act_n          (c0_ddr4_act_n),
   .c0_ddr4_adr            (c0_ddr4_adr),
   .c0_ddr4_ba             (c0_ddr4_ba),
   .c0_ddr4_bg             (c0_ddr4_bg),
   .c0_ddr4_cke            (c0_ddr4_cke),
   .c0_ddr4_odt            (c0_ddr4_odt),
   .c0_ddr4_cs_n           (c0_ddr4_cs_n),
   .c0_ddr4_ck_t           (c0_ddr4_ck_t),
   .c0_ddr4_ck_c           (c0_ddr4_ck_c),
   .c0_ddr4_reset_n        (c0_ddr4_reset_n),

     .c0_ddr4_parity                        (c0_ddr4_parity),
   .c0_ddr4_dq             (c0_ddr4_dq),
   .c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
   .c0_ddr4_dqs_t          (c0_ddr4_dqs_t),

   .c0_ddr4_ui_clk                (c0_ddr4_clk),
   .c0_ddr4_ui_clk_sync_rst       (c0_ddr4_rst),
   .addn_ui_clkout1                            (),
   .dbg_clk                                    (),
     // AXI CTRL port
     .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_awready       (),
     .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
     // Slave Interface Write Data Ports
     .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
     .c0_ddr4_s_axi_ctrl_wready        (),
     .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
     // Slave Interface Write Response Ports
     .c0_ddr4_s_axi_ctrl_bvalid        (),
     .c0_ddr4_s_axi_ctrl_bready        (1'b1),
     .c0_ddr4_s_axi_ctrl_bresp         (),
     // Slave Interface Read Address Ports
     .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_arready       (),
     .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
     // Slave Interface Read Data Ports
     .c0_ddr4_s_axi_ctrl_rvalid        (),
     .c0_ddr4_s_axi_ctrl_rready        (1'b1),
     .c0_ddr4_s_axi_ctrl_rdata         (),
     .c0_ddr4_s_axi_ctrl_rresp         (),
     // Interrupt output
     .c0_ddr4_interrupt                (),
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn                     (hbm_axi[0].arstn),
  .c0_ddr4_s_axi_awid                  (hbm_axi[0].awid),
  .c0_ddr4_s_axi_awaddr                (hbm_axi[0].awaddr),
  .c0_ddr4_s_axi_awlen                 (hbm_axi[0].awlen),
  .c0_ddr4_s_axi_awsize                (hbm_axi[0].awsize),
  .c0_ddr4_s_axi_awburst               (hbm_axi[0].awburst),
  .c0_ddr4_s_axi_awlock                (hbm_axi[0].awlock),
  .c0_ddr4_s_axi_awcache               (hbm_axi[0].awcache),
  .c0_ddr4_s_axi_awprot                (hbm_axi[0].awprot),
  .c0_ddr4_s_axi_awqos                 (hbm_axi[0].awqos),
  .c0_ddr4_s_axi_awvalid               (hbm_axi[0].awvalid),
  .c0_ddr4_s_axi_awready               (hbm_axi[0].awready),
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata                 (hbm_axi[0].wdata),
  .c0_ddr4_s_axi_wstrb                 (hbm_axi[0].wstrb),
  .c0_ddr4_s_axi_wlast                 (hbm_axi[0].wlast),
  .c0_ddr4_s_axi_wvalid                (hbm_axi[0].wvalid),
  .c0_ddr4_s_axi_wready                (hbm_axi[0].wready),
  // Slave Interface Write Response Ports
  .c0_ddr4_s_axi_bid                   (hbm_axi[0].bid),
  .c0_ddr4_s_axi_bresp                 (hbm_axi[0].bresp),
  .c0_ddr4_s_axi_bvalid                (hbm_axi[0].bvalid),
  .c0_ddr4_s_axi_bready                (hbm_axi[0].bready),
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid                  (hbm_axi[0].arid),
  .c0_ddr4_s_axi_araddr                (hbm_axi[0].araddr),
  .c0_ddr4_s_axi_arlen                 (hbm_axi[0].arlen),
  .c0_ddr4_s_axi_arsize                (hbm_axi[0].arsize),
  .c0_ddr4_s_axi_arburst               (hbm_axi[0].arburst),
  .c0_ddr4_s_axi_arlock                (hbm_axi[0].arlock),
  .c0_ddr4_s_axi_arcache               (hbm_axi[0].arcache),
  .c0_ddr4_s_axi_arprot                (hbm_axi[0].arprot),
  .c0_ddr4_s_axi_arqos                 (hbm_axi[0].arqos),
  .c0_ddr4_s_axi_arvalid               (hbm_axi[0].arvalid),
  .c0_ddr4_s_axi_arready               (hbm_axi[0].arready),
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rid                   (hbm_axi[0].rid),
  .c0_ddr4_s_axi_rdata                 (hbm_axi[0].rdata),
  .c0_ddr4_s_axi_rresp                 (hbm_axi[0].rresp),
  .c0_ddr4_s_axi_rlast                 (hbm_axi[0].rlast),
  .c0_ddr4_s_axi_rvalid                (hbm_axi[0].rvalid),
  .c0_ddr4_s_axi_rready                (hbm_axi[0].rready),
  
  // Debug Port
  .dbg_bus         ()                                             

  ); 




ddr4_1 u_ddr4_1
  (
   .sys_rst           (1'b0),

   .c0_sys_clk_i                   (DDR1_sys_clk),
   .c0_init_calib_complete (),
   .c0_ddr4_act_n          (c1_ddr4_act_n),
   .c0_ddr4_adr            (c1_ddr4_adr),
   .c0_ddr4_ba             (c1_ddr4_ba),
   .c0_ddr4_bg             (c1_ddr4_bg),
   .c0_ddr4_cke            (c1_ddr4_cke),
   .c0_ddr4_odt            (c1_ddr4_odt),
   .c0_ddr4_cs_n           (c1_ddr4_cs_n),
   .c0_ddr4_ck_t           (c1_ddr4_ck_t),
   .c0_ddr4_ck_c           (c1_ddr4_ck_c),
   .c0_ddr4_reset_n        (c1_ddr4_reset_n),

     .c0_ddr4_parity                        (c1_ddr4_parity),
   .c0_ddr4_dq             (c1_ddr4_dq),
   .c0_ddr4_dqs_c          (c1_ddr4_dqs_c),
   .c0_ddr4_dqs_t          (c1_ddr4_dqs_t),

   .c0_ddr4_ui_clk                (c1_ddr4_clk),
   .c0_ddr4_ui_clk_sync_rst       (c1_ddr4_rst),
   .addn_ui_clkout1                            (),
   .dbg_clk                                    (),
     // AXI CTRL port
     .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_awready       (),
     .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
     // Slave Interface Write Data Ports
     .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
     .c0_ddr4_s_axi_ctrl_wready        (),
     .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
     // Slave Interface Write Response Ports
     .c0_ddr4_s_axi_ctrl_bvalid        (),
     .c0_ddr4_s_axi_ctrl_bready        (1'b1),
     .c0_ddr4_s_axi_ctrl_bresp         (),
     // Slave Interface Read Address Ports
     .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_arready       (),
     .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
     // Slave Interface Read Data Ports
     .c0_ddr4_s_axi_ctrl_rvalid        (),
     .c0_ddr4_s_axi_ctrl_rready        (1'b1),
     .c0_ddr4_s_axi_ctrl_rdata         (),
     .c0_ddr4_s_axi_ctrl_rresp         (),
     // Interrupt output
     .c0_ddr4_interrupt                (),
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn                     (hbm_axi[1].arstn),
  .c0_ddr4_s_axi_awid                  (hbm_axi[1].awid),
  .c0_ddr4_s_axi_awaddr                (hbm_axi[1].awaddr),
  .c0_ddr4_s_axi_awlen                 (hbm_axi[1].awlen),
  .c0_ddr4_s_axi_awsize                (hbm_axi[1].awsize),
  .c0_ddr4_s_axi_awburst               (hbm_axi[1].awburst),
  .c0_ddr4_s_axi_awlock                (hbm_axi[1].awlock),
  .c0_ddr4_s_axi_awcache               (hbm_axi[1].awcache),
  .c0_ddr4_s_axi_awprot                (hbm_axi[1].awprot),
  .c0_ddr4_s_axi_awqos                 (hbm_axi[1].awqos),
  .c0_ddr4_s_axi_awvalid               (hbm_axi[1].awvalid),
  .c0_ddr4_s_axi_awready               (hbm_axi[1].awready),
  // Slave Interface Write Data Ports           
  .c0_ddr4_s_axi_wdata                 (hbm_axi[1].wdata),
  .c0_ddr4_s_axi_wstrb                 (hbm_axi[1].wstrb),
  .c0_ddr4_s_axi_wlast                 (hbm_axi[1].wlast),
  .c0_ddr4_s_axi_wvalid                (hbm_axi[1].wvalid),
  .c0_ddr4_s_axi_wready                (hbm_axi[1].wready),
  // Slave Interface Write Response Ports       
  .c0_ddr4_s_axi_bid                   (hbm_axi[1].bid),
  .c0_ddr4_s_axi_bresp                 (hbm_axi[1].bresp),
  .c0_ddr4_s_axi_bvalid                (hbm_axi[1].bvalid),
  .c0_ddr4_s_axi_bready                (hbm_axi[1].bready),
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid                  (hbm_axi[1].arid),
  .c0_ddr4_s_axi_araddr                (hbm_axi[1].araddr),
  .c0_ddr4_s_axi_arlen                 (hbm_axi[1].arlen),
  .c0_ddr4_s_axi_arsize                (hbm_axi[1].arsize),
  .c0_ddr4_s_axi_arburst               (hbm_axi[1].arburst),
  .c0_ddr4_s_axi_arlock                (hbm_axi[1].arlock),
  .c0_ddr4_s_axi_arcache               (hbm_axi[1].arcache),
  .c0_ddr4_s_axi_arprot                (hbm_axi[1].arprot),
  .c0_ddr4_s_axi_arqos                 (hbm_axi[1].arqos),
  .c0_ddr4_s_axi_arvalid               (hbm_axi[1].arvalid),
  .c0_ddr4_s_axi_arready               (hbm_axi[1].arready),
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rid                   (hbm_axi[1].rid),
  .c0_ddr4_s_axi_rdata                 (hbm_axi[1].rdata),
  .c0_ddr4_s_axi_rresp                 (hbm_axi[1].rresp),
  .c0_ddr4_s_axi_rlast                 (hbm_axi[1].rlast),
  .c0_ddr4_s_axi_rvalid                (hbm_axi[1].rvalid),
  .c0_ddr4_s_axi_rready                (hbm_axi[1].rready),
  
  // Debug Port
  .dbg_bus         ()                                             

  ); 












endmodule