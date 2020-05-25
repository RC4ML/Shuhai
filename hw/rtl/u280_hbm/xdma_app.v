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

`timescale 1ps / 1ps
module xdma_app #(
  parameter TCQ                         = 1,
  parameter C_M_AXI_ID_WIDTH            = 4,
  parameter PL_LINK_CAP_MAX_LINK_WIDTH  = 16,
  parameter C_DATA_WIDTH                = 512,
  parameter C_M_AXI_DATA_WIDTH          = C_DATA_WIDTH,
  parameter C_S_AXI_DATA_WIDTH          = C_DATA_WIDTH,
  parameter C_S_AXIS_DATA_WIDTH         = C_DATA_WIDTH,
  parameter C_M_AXIS_DATA_WIDTH         = C_DATA_WIDTH,
  parameter C_M_AXIS_RQ_USER_WIDTH      = ((C_DATA_WIDTH == 512) ? 137 : 62),
  parameter C_S_AXIS_CQP_USER_WIDTH     = ((C_DATA_WIDTH == 512) ? 183 : 88),
  parameter C_M_AXIS_RC_USER_WIDTH      = ((C_DATA_WIDTH == 512) ? 161 : 75),
  parameter C_S_AXIS_CC_USER_WIDTH      = ((C_DATA_WIDTH == 512) ?  81 : 33),
  parameter C_S_KEEP_WIDTH              = C_S_AXI_DATA_WIDTH / 32,
  parameter C_M_KEEP_WIDTH              = (C_M_AXI_DATA_WIDTH / 32),
  parameter C_XDMA_NUM_CHNL             = 2,
  parameter N_MEM_INTF					        = 32
)
(

  // AXI Lite Master Interface connections
  input  wire  [31:0] s_axil_awaddr,
  input  wire         s_axil_awvalid,
  output wire         s_axil_awready,
  input  wire  [31:0] s_axil_wdata,
  input  wire   [3:0] s_axil_wstrb,
  input  wire         s_axil_wvalid,
  output wire         s_axil_wready,
  output wire   [1:0] s_axil_bresp,
  output wire         s_axil_bvalid,
  input  wire         s_axil_bready,
  input  wire  [31:0] s_axil_araddr,
  input  wire         s_axil_arvalid,
  output wire         s_axil_arready,
  output wire  [31:0] s_axil_rdata,
  output wire   [1:0] s_axil_rresp,
  output wire         s_axil_rvalid,
  input  wire         s_axil_rready,


//VU9P_TUL_EX_String= FALSE

  // AXI Memory Mapped interface
  input  wire  [C_M_AXI_ID_WIDTH-1:0] s_axi_awid,
  input  wire  [64-1:0] s_axi_awaddr,
  input  wire   [7:0] s_axi_awlen,
  input  wire   [2:0] s_axi_awsize,
  input  wire   [1:0] s_axi_awburst,
  input  wire         s_axi_awvalid,
  output wire         s_axi_awready,
  input  wire [C_M_AXI_DATA_WIDTH-1:0]        s_axi_wdata,
  input  wire [(C_M_AXI_DATA_WIDTH/8)-1:0]    s_axi_wstrb,
  input  wire         s_axi_wlast,
  input  wire         s_axi_wvalid,
  output wire         s_axi_wready,
  output wire [C_M_AXI_ID_WIDTH-1:0]          s_axi_bid,
  output wire   [1:0] s_axi_bresp,
  output wire         s_axi_bvalid,
  input  wire         s_axi_bready,
  input  wire [C_M_AXI_ID_WIDTH-1:0]          s_axi_arid,
  input  wire  [64-1:0] s_axi_araddr,
  input  wire   [7:0] s_axi_arlen,
  input  wire   [2:0] s_axi_arsize,
  input  wire   [1:0] s_axi_arburst,
  input  wire         s_axi_arvalid,
  output wire         s_axi_arready,
  output wire   [C_M_AXI_ID_WIDTH-1:0]        s_axi_rid,
  output wire   [C_M_AXI_DATA_WIDTH-1:0]      s_axi_rdata,
  output wire   [1:0] s_axi_rresp,
  output wire         s_axi_rlast,
  output wire         s_axi_rvalid,
  input  wire         s_axi_rready,

  // AXI stream interface for the CQ forwarding
  input  wire  [C_M_AXI_ID_WIDTH-1:0]  s_axib_awid,
  input  wire  [18:0] s_axib_awaddr,
  input  wire   [7:0] s_axib_awlen,
  input  wire   [2:0] s_axib_awsize,
  input  wire   [1:0] s_axib_awburst,
  input  wire         s_axib_awvalid,
  output wire         s_axib_awready,
  input  wire  [C_M_AXI_DATA_WIDTH-1:0]        s_axib_wdata,
  input  wire  [(C_M_AXI_DATA_WIDTH/8)-1:0]    s_axib_wstrb,
  input  wire         s_axib_wlast,
  input  wire         s_axib_wvalid,
  output wire         s_axib_wready,
  output wire  [C_M_AXI_ID_WIDTH-1:0]          s_axib_bid,
  output wire   [1:0] s_axib_bresp,
  output wire         s_axib_bvalid,
  input  wire         s_axib_bready,
  input  wire [C_M_AXI_ID_WIDTH-1:0]           s_axib_arid,
  input  wire  [18:0] s_axib_araddr,
  input  wire   [7:0] s_axib_arlen,
  input  wire   [2:0] s_axib_arsize,
  input  wire   [1:0] s_axib_arburst,
  input  wire         s_axib_arvalid,
  output wire         s_axib_arready,
  output wire [C_M_AXI_ID_WIDTH-1:0]           s_axib_rid,
  output wire [C_M_AXI_DATA_WIDTH-1:0]         s_axib_rdata,
  output wire   [1:0] s_axib_rresp,
  output wire         s_axib_rlast,
  output wire         s_axib_rvalid,
  input  wire         s_axib_rready,

  // System IO signals
  input  wire         user_resetn,
  input  wire         sys_rst_n,
 
  input  wire         user_clk,
  input  wire         user_lnk_up,
  output wire   [3:0] leds,

  //
	  input          		                hbm_axi_clk,
    output                            hbm_reset,
    output        [ 31:0]             work_group_size,
    output        [ 31:0]             stride,
    output        [ 63:0]             num_mem_ops,
    output        [ 31:0]             mem_burst_size,
    output        [ 33:0]             initial_addr,
    output        [  7:0]             hbm_channel,
    output [N_MEM_INTF-1:0]           write_enable,
    output [N_MEM_INTF-1:0]           read_enable,
    output                            latency_test_enable,
    output                            start,

    input  [N_MEM_INTF-1:0]           end_wr,
    input  [N_MEM_INTF-1:0]           end_rd,
    input         [ 31:0]             lat_timer_sum_wr,
    input         [ 31:0]             lat_timer_sum_rd,
    input                             lat_timer_valid , //log down lat_timer when lat_timer_valid is 1. 
    input         [15:0]              lat_timer       

);			
  // wire/reg declarations
  wire            sys_reset;
  reg  [25:0]     user_clk_heartbeat;



  // The sys_rst_n input is active low based on the core configuration
  assign sys_resetn = sys_rst_n;

  // Create a Clock Heartbeat
  always @(posedge user_clk) begin
    if(!sys_resetn) begin
      user_clk_heartbeat <= #TCQ 26'd0;
    end else begin
      user_clk_heartbeat <= #TCQ user_clk_heartbeat + 1'b1;
    end
  end

  // LEDs for observation
  assign leds[0] = sys_resetn;
  assign leds[1] = user_resetn;
  assign leds[2] = user_lnk_up;
  assign leds[3] = user_clk_heartbeat[25];


 xdma_control xdma_control_inst(
    .s_aclk        (user_clk),
    .s_aresetn     (user_resetn),
  // AXI Lite Master Interface connections
    .s_axil_awaddr  (s_axil_awaddr[31:0]),
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awready (s_axil_awready),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wstrb   (s_axil_wstrb),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bready  (s_axil_bready),
    .s_axil_araddr  (s_axil_araddr[31:0]),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_arready (s_axil_arready),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rready  (s_axil_rready),

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
    .end_wr             (end_wr),
    .end_rd             (end_rd),
    .lat_timer_sum_wr   (lat_timer_sum_wr),
    .lat_timer_sum_rd   (lat_timer_sum_rd),
  	.lat_timer_valid    (lat_timer_valid),
    .lat_timer          (lat_timer)
      
    );




	  // Block ram for the AXI interface
	  axi_bram_ctrl_1 axi_bram_xdma_inst (
	    .s_axi_aclk      (user_clk),
	    .s_axi_aresetn   (user_resetn),
	    .s_axi_awid      (s_axi_awid ),
	    .s_axi_awaddr    (s_axi_awaddr[18:0]),
	    .s_axi_awlen     (s_axi_awlen),
	    .s_axi_awsize    (s_axi_awsize),
	    .s_axi_awburst   (s_axi_awburst),
	    .s_axi_awlock    (1'd0),
	    .s_axi_awcache   (4'd0),
	    .s_axi_awprot    (3'd0),
	    .s_axi_awvalid   (s_axi_awvalid),
	    .s_axi_awready   (s_axi_awready),
	    .s_axi_wdata     (s_axi_wdata),
	    .s_axi_wstrb     (s_axi_wstrb),
	    .s_axi_wlast     (s_axi_wlast),
	    .s_axi_wvalid    (s_axi_wvalid),
	    .s_axi_wready    (s_axi_wready),
	    .s_axi_bid       (s_axi_bid),
	    .s_axi_bresp     (s_axi_bresp),
	    .s_axi_bvalid    (s_axi_bvalid),
	    .s_axi_bready    (s_axi_bready),
	    .s_axi_arid      (s_axi_arid),
	    .s_axi_araddr    (s_axi_araddr[18:0]),
	    .s_axi_arlen     (s_axi_arlen),
	    .s_axi_arsize    (s_axi_arsize),
	    .s_axi_arburst   (s_axi_arburst),
	    .s_axi_arlock    (1'd0),
	    .s_axi_arcache   (4'd0),
	    .s_axi_arprot    (3'd0),
	    .s_axi_arvalid   (s_axi_arvalid),
	    .s_axi_arready   (s_axi_arready),
	    .s_axi_rid       (s_axi_rid),
	    .s_axi_rdata     (s_axi_rdata),
	    .s_axi_rresp     (s_axi_rresp),
	    .s_axi_rlast     (s_axi_rlast),
	    .s_axi_rvalid    (s_axi_rvalid),
	    .s_axi_rready    (s_axi_rready )
	  );

  // AXI stream interface for the CQ forwarding
  axi_bram_ctrl_1 axi_bram_gen_bypass_inst (
    .s_axi_aclk      (user_clk),
    .s_axi_aresetn   (user_resetn),
    .s_axi_awid      (s_axib_awid ),
    .s_axi_awaddr    (s_axib_awaddr[18:0]),
    .s_axi_awlen     (s_axib_awlen),
    .s_axi_awsize    (s_axib_awsize),
    .s_axi_awburst   (s_axib_awburst),
    .s_axi_awlock    (1'd0),
    .s_axi_awcache   (4'd0),
    .s_axi_awprot    (3'd0),
    .s_axi_awvalid   (s_axib_awvalid),
    .s_axi_awready   (s_axib_awready),
    .s_axi_wdata     (s_axib_wdata),
    .s_axi_wstrb     (s_axib_wstrb),
    .s_axi_wlast     (s_axib_wlast),
    .s_axi_wvalid    (s_axib_wvalid),
    .s_axi_wready    (s_axib_wready),
    .s_axi_bid       (s_axib_bid),
    .s_axi_bresp     (s_axib_bresp),
    .s_axi_bvalid    (s_axib_bvalid),
    .s_axi_bready    (s_axib_bready),
    .s_axi_arid      (s_axib_arid),
    .s_axi_araddr    (s_axib_araddr[18:0]),
    .s_axi_arlen     (s_axib_arlen),
    .s_axi_arsize    (s_axib_arsize),
    .s_axi_arburst   (s_axib_arburst),
    .s_axi_arlock    (1'd0),
    .s_axi_arcache   (4'd0),
    .s_axi_arprot    (3'd0),
    .s_axi_arvalid   (s_axib_arvalid),
    .s_axi_arready   (s_axib_arready),
    .s_axi_rid       (s_axib_rid),
    .s_axi_rdata     (s_axib_rdata),
    .s_axi_rresp     (s_axib_rresp),
    .s_axi_rlast     (s_axib_rlast),
    .s_axi_rvalid    (s_axib_rvalid),
    .s_axi_rready    (s_axib_rready )
  );





endmodule
