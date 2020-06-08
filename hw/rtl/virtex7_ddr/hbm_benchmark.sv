////////////////////////////////////////////////////////////////////////////////
// Instantiating MMCM for AXI clock generation

//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_out1__100.00000______0.000______50.0______130.958_____98.575
// clk_out2__200.00000______0.000______50.0______114.829_____98.575
// clk_out3__250.00000______0.000______50.0______110.209_____98.575
// clk_out4__333.33333______0.000______50.0______104.542_____98.575
// clk_out5__333.33333______0.000______50.0______104.542_____98.575

`include "hbm_bench.vh"


module hbm_benchmark#(
    parameter N_MEM_INTF    = 2,
    parameter AXI_CHANNELS  = 2,
    parameter PL_LINK_CAP_MAX_LINK_WIDTH          = 8,            // 1- X1; 2 - X2; 4 - X4; 8 - X8
   parameter PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
   parameter PL_LINK_CAP_MAX_LINK_SPEED          = 4,             // 1- GEN1; 2 - GEN2; 4 - GEN3
   parameter C_DATA_WIDTH                        = 256 ,
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
 
    // Connection to SODIMM-A
    // Inouts
    inout wire [71:0]                    c0_ddr3_dq,
    inout wire [8:0]                     c0_ddr3_dqs_n,
    inout wire [8:0]                     c0_ddr3_dqs_p,
    output wire [15:0]                   c0_ddr3_addr,
    output wire [2:0]                    c0_ddr3_ba,
    output wire                          c0_ddr3_ras_n,
    output wire                          c0_ddr3_cas_n,
    output wire                          c0_ddr3_we_n,
    output wire                          c0_ddr3_reset_n,
    output wire [1:0]                    c0_ddr3_ck_p,
    output wire [1:0]                    c0_ddr3_ck_n,
    output wire [1:0]                    c0_ddr3_cke,
    output wire [1:0]                    c0_ddr3_cs_n,
    output wire [1:0]                    c0_ddr3_odt,
    // Differential system clocks
    input wire                           c0_sys_clk_p,
    input wire                           c0_sys_clk_n,
    // differential iodelayctrl clk (reference clock)
    input wire                           clk_ref_p,
    input wire                           clk_ref_n,
    // Inouts
    inout wire [71:0]                    c1_ddr3_dq,
    inout wire [8:0]                     c1_ddr3_dqs_n,
    inout wire [8:0]                     c1_ddr3_dqs_p,
    output wire [15:0]                   c1_ddr3_addr,
    output wire [2:0]                    c1_ddr3_ba,
    output wire                          c1_ddr3_ras_n,
    output wire                          c1_ddr3_cas_n,
    output wire                          c1_ddr3_we_n,
    output wire                          c1_ddr3_reset_n,
    output wire [1:0]                    c1_ddr3_ck_p,
    output wire [1:0]                    c1_ddr3_ck_n,
    output wire [1:0]                    c1_ddr3_cke,
    output wire [1:0]                    c1_ddr3_cs_n,
    output wire [1:0]                    c1_ddr3_odt,
    // Differential system clocks
    input wire                           c1_sys_clk_p,
    input wire                           c1_sys_clk_n,             
    input wire                           pok_dram, //used as reset to ddr
    output wire[8:0]                     c0_ddr3_dm,
    output wire[8:0]                     c1_ddr3_dm,
    output wire[1:0]                     dram_on

);

// uwire c0_sys_clk;

// IBUFDS_GTE2 #(
//             .CLKCM_CFG("TRUE"),   // Refer to Transceiver User Guide
//             .CLKRCV_TRST("TRUE"), // Refer to Transceiver User Guide
//             .CLKSWING_CFG(2'b11)  // Refer to Transceiver User Guide
//          )
//          IBUFDS_GTE2_inst (
//             .O(c0_sys_clk),         // 1-bit output: Refer to Transceiver User Guide
//             .ODIV2(),            // 1-bit output: Refer to Transceiver User Guide
//             .CEB(1'b0),          // 1-bit input: Refer to Transceiver User Guide
//             .I(c0_sys_clk_p),        // 1-bit input: Refer to Transceiver User Guide
//             .IB(c0_sys_clk_n)        // 1-bit input: Refer to Transceiver User Guide
//         );


// reg ff;

// always @ (posedge c0_sys_clk) begin
//     ff <= ~ff;
// end


// ila_bench inst_debug_bench (
//    .clk (c0_sys_clk),

//    .probe0  (ff), //1
//    .probe1  (), //1
//    .probe2  (), //1
//    .probe3  (), //1
//    .probe4  (), //1
//    .probe5  (), //1
//    .probe6  (), //1
//    .probe7  ()  //1
// );

// assign dram_on = 2'b11;
// assign c0_ddr3_dm = 9'h0;
// assign c1_ddr3_dm = 9'h0;



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


    wire                      user_clk;
    wire                        user_resetn;


assign dram_on = 2'b11;
assign c0_ddr3_dm = 9'h0;
assign c1_ddr3_dm = 9'h0;


AXI #(
    .ADDR_WIDTH    (33 ), 
    .DATA_WIDTH    (512),
    .PARAMS_BITS   (256),
    .ID_WIDTH      (4  ),
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

    

  assign lat_timer_sum_wr_o = lat_timer_sum_wr[hbm_channel][31:0];
  assign lat_timer_sum_rd_o = lat_timer_sum_rd[hbm_channel][31:0];



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
  // IBUFDS_GTE4 # (.REFCLK_HROW_CK_SEL(2'b00)) refclk_ibuf (.O(sys_clk), .ODIV2(), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));

  IBUFDS_GTE2 #(
            .CLKCM_CFG("TRUE"),   // Refer to Transceiver User Guide
            .CLKRCV_TRST("TRUE"), // Refer to Transceiver User Guide
            .CLKSWING_CFG(2'b11)  // Refer to Transceiver User Guide
         )
         IBUFDS_GTE2_inst (
            .O(sys_clk),         // 1-bit output: Refer to Transceiver User Guide
            .ODIV2(),            // 1-bit output: Refer to Transceiver User Guide
            .CEB(1'b0),          // 1-bit input: Refer to Transceiver User Guide
            .I(sys_clk_p),        // 1-bit input: Refer to Transceiver User Guide
            .IB(sys_clk_n)        // 1-bit input: Refer to Transceiver User Guide
        );

  // Reset buffer
  IBUF   sys_reset_n_ibuf (.O(sys_rst_n_c), .I(sys_rst_n));



  // Core Top Level Wrapper
  xdma_ip dma_inst
     (
      //---------------------------------------------------------------------------------------//
      //  PCI Express (pci_exp) Interface                                                      //
      //---------------------------------------------------------------------------------------//

      .sys_rst_n       ( sys_rst_n_c ),
      .sys_clk         ( sys_clk ),
      // .sys_clk_gt      ( sys_clk_gt),
      
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


wire                  c0_ddr3_clk;
wire                  c0_ddr3_rst;
reg                   c0_ddr3_aresetn;
wire                  c1_ddr3_clk;
wire                  c1_ddr3_rst;
reg                   c1_ddr3_aresetn;


always @ (posedge c0_ddr3_clk) begin
  c0_ddr3_aresetn <= ~c0_ddr3_rst & c0_mmcm_locked;
end

always @ (posedge c1_ddr3_clk) begin
  c1_ddr3_aresetn <= ~c1_ddr3_rst & c1_mmcm_locked;
end

// assign c1_ddr3_aresetn = ~c1_ddr3_rst & c1_mmcm_locked;
// assign c0_ddr3_aresetn = ~c0_ddr3_rst & c0_mmcm_locked;


assign hbm_axi[0].clk   = c0_ddr3_clk;
assign hbm_axi[1].clk   = c1_ddr3_clk;
assign hbm_axi[0].arstn = c0_ddr3_aresetn & (~hbm_reset);
assign hbm_axi[1].arstn = c1_ddr3_aresetn & (~hbm_reset);

uwire c0_init_calib_complete, c1_init_calib_complete;

ila_bench inst_debug_bench (
   .clk (sys_clk),

   .probe0  (c0_ddr3_rst), //1
   .probe1  (c0_mmcm_locked), //1
   .probe2  (c1_ddr3_rst), //1
   .probe3  (c1_mmcm_locked), //1
   .probe4  (c0_init_calib_complete), //1
   .probe5  (c1_init_calib_complete), //1
   .probe6  (c0_ddr3_aresetn), //1
   .probe7  (start_wr[0])  //1
);

mig_7series_0 u_mig_7series_0 (
  // Memory interface ports
  .c0_ddr3_addr                         (c0_ddr3_addr),            // output [13:0]        c0_ddr3_addr
  .c0_ddr3_ba                           (c0_ddr3_ba),              // output [2:0]        c0_ddr3_ba
  .c0_ddr3_cas_n                        (c0_ddr3_cas_n),           // output            c0_ddr3_cas_n
  .c0_ddr3_ck_n                         (c0_ddr3_ck_n),            // output [0:0]        c0_ddr3_ck_n
  .c0_ddr3_ck_p                         (c0_ddr3_ck_p),            // output [0:0]        c0_ddr3_ck_p
  .c0_ddr3_cke                          (c0_ddr3_cke),             // output [0:0]        c0_ddr3_cke
  .c0_ddr3_ras_n                        (c0_ddr3_ras_n),           // output            c0_ddr3_ras_n
  .c0_ddr3_reset_n                      (c0_ddr3_reset_n),         // output            c0_ddr3_reset_n
  .c0_ddr3_we_n                         (c0_ddr3_we_n),            // output            c0_ddr3_we_n
  .c0_ddr3_dq                           (c0_ddr3_dq),              // inout [63:0]        c0_ddr3_dq
  .c0_ddr3_dqs_n                        (c0_ddr3_dqs_n),           // inout [7:0]        c0_ddr3_dqs_n
  .c0_ddr3_dqs_p                        (c0_ddr3_dqs_p),           // inout [7:0]        c0_ddr3_dqs_p
  .c0_init_calib_complete               (c0_init_calib_complete),  // output            init_calib_complete
    
  .c0_ddr3_cs_n                         (c0_ddr3_cs_n),            // output [0:0]        c0_ddr3_cs_n
  .c0_ddr3_odt                          (c0_ddr3_odt),             // output [0:0]        c0_ddr3_odt
  // Application interface ports        
  .c0_ui_clk                            (c0_ddr3_clk),               // output            c0_ddr3_clk
  .c0_ui_clk_sync_rst                   (c0_ddr3_rst),              // output            c0_ddr3_rst
  .c0_mmcm_locked                       (c0_mmcm_locked),          // output            c0_mmcm_locked
  .c0_aresetn                           (c0_ddr3_aresetn),            // input            c0_aresetn
  .c0_app_sr_req                        (0),                       // input            c0_app_sr_req
  .c0_app_ref_req                       (0),                       // input            c0_app_ref_req
  .c0_app_zq_req                        (0),                       // input            c0_app_zq_req
  .c0_app_sr_active                     (),        // output            c0_app_sr_active
  .c0_app_ref_ack                       (),          // output            c0_app_ref_ack
  .c0_app_zq_ack                        (),           // output            c0_app_zq_ack
  // Slave Interface Write Address Ports
  .c0_s_axi_awid                  (hbm_axi[0].awid),  
  .c0_s_axi_awaddr                (hbm_axi[0].awaddr),
  .c0_s_axi_awlen                 (hbm_axi[0].awlen),
  .c0_s_axi_awsize                (hbm_axi[0].awsize),
  .c0_s_axi_awburst               (hbm_axi[0].awburst),
  .c0_s_axi_awlock                (hbm_axi[0].awlock),
  .c0_s_axi_awcache               (hbm_axi[0].awcache),
  .c0_s_axi_awprot                (hbm_axi[0].awprot),
  .c0_s_axi_awqos                 (hbm_axi[0].awqos),
  .c0_s_axi_awvalid               (hbm_axi[0].awvalid),
  .c0_s_axi_awready               (hbm_axi[0].awready),

  // Slave Interface Write Data Ports
  .c0_s_axi_wdata                 (hbm_axi[0].wdata),
  .c0_s_axi_wstrb                 (hbm_axi[0].wstrb),
  .c0_s_axi_wlast                 (hbm_axi[0].wlast),
  .c0_s_axi_wvalid                (hbm_axi[0].wvalid),
  .c0_s_axi_wready                (hbm_axi[0].wready),
  // Slave Interface Write Response Ports
  .c0_s_axi_bid                   (hbm_axi[0].bid),
  .c0_s_axi_bresp                 (hbm_axi[0].bresp),
  .c0_s_axi_bvalid                (hbm_axi[0].bvalid),
  .c0_s_axi_bready                (hbm_axi[0].bready),
  // Slave Interface Read Address Ports
  .c0_s_axi_arid                  (hbm_axi[0].arid),
  .c0_s_axi_araddr                (hbm_axi[0].araddr),
  .c0_s_axi_arlen                 (hbm_axi[0].arlen),
  .c0_s_axi_arsize                (hbm_axi[0].arsize),
  .c0_s_axi_arburst               (hbm_axi[0].arburst),
  .c0_s_axi_arlock                (hbm_axi[0].arlock),
  .c0_s_axi_arcache               (hbm_axi[0].arcache),
  .c0_s_axi_arprot                (hbm_axi[0].arprot),
  .c0_s_axi_arqos                 (hbm_axi[0].arqos),
  .c0_s_axi_arvalid               (hbm_axi[0].arvalid),
  .c0_s_axi_arready               (hbm_axi[0].arready),
  // Slave Interface Read Data Ports
  .c0_s_axi_rid                   (hbm_axi[0].rid),
  .c0_s_axi_rdata                 (hbm_axi[0].rdata),
  .c0_s_axi_rresp                 (hbm_axi[0].rresp),
  .c0_s_axi_rlast                 (hbm_axi[0].rlast),
  .c0_s_axi_rvalid                (hbm_axi[0].rvalid),
  .c0_s_axi_rready                (hbm_axi[0].rready),
  // AXI CTRL port
  .c0_s_axi_ctrl_awvalid                (0),                       // input            c0_s_axi_ctrl_awvalid
  .c0_s_axi_ctrl_awready                (),   // output            c0_s_axi_ctrl_awready
  .c0_s_axi_ctrl_awaddr                 (0),                       // input [31:0]            c0_s_axi_ctrl_awaddr
  // Slave Interface Write Data Ports   
  .c0_s_axi_ctrl_wvalid                 (0),                       // input            c0_s_axi_ctrl_wvalid
  .c0_s_axi_ctrl_wready                 (),    // output            c0_s_axi_ctrl_wready
  .c0_s_axi_ctrl_wdata                  (0),                       // input [31:0]            c0_s_axi_ctrl_wdata
  // Slave Interface Write Response Ports
  .c0_s_axi_ctrl_bvalid                 (),    // output            c0_s_axi_ctrl_bvalid
  .c0_s_axi_ctrl_bready                 (1),                       // input            c0_s_axi_ctrl_bready
  .c0_s_axi_ctrl_bresp                  (),     // output [1:0]            c0_s_axi_ctrl_bresp
  // Slave Interface Read Address Ports
  .c0_s_axi_ctrl_arvalid                (0),                       // input            c0_s_axi_ctrl_arvalid
  .c0_s_axi_ctrl_arready                (),   // output            c0_s_axi_ctrl_arready
  .c0_s_axi_ctrl_araddr                 (0),                       // input [31:0]            c0_s_axi_ctrl_araddr
  // Slave Interface Read Data Ports
  .c0_s_axi_ctrl_rvalid                 (),    // output            c0_s_axi_ctrl_rvalid
  .c0_s_axi_ctrl_rready                 (1),                       // input            c0_s_axi_ctrl_rready
  .c0_s_axi_ctrl_rdata                  (),     // output [31:0]            c0_s_axi_ctrl_rdata
  .c0_s_axi_ctrl_rresp                  (),     // output [1:0]            c0_s_axi_ctrl_rresp
  // Interrupt output
  .c0_interrupt                         (),                        // output            c0_interrupt
  .c0_app_ecc_multiple_err              (), // output [7:0]            c0_app_ecc_multiple_err
  // System Clock Ports
  .c0_sys_clk_p                         (c0_sys_clk_p),           // input                c0_sys_clk_p
  .c0_sys_clk_n                         (c0_sys_clk_n),           // input                c0_sys_clk_n
  // Reference Clock Ports
  .clk_ref_p                            (clk_ref_p),                  // input                clk_ref_p
  .clk_ref_n                            (clk_ref_n),                  // input                clk_ref_n
  // Memory interface ports
  .c1_ddr3_addr                         (c1_ddr3_addr),            // output [13:0]        c1_ddr3_addr
  .c1_ddr3_ba                           (c1_ddr3_ba),              // output [2:0]        c1_ddr3_ba
  .c1_ddr3_cas_n                        (c1_ddr3_cas_n),           // output            c1_ddr3_cas_n
  .c1_ddr3_ck_n                         (c1_ddr3_ck_n),            // output [0:0]        c1_ddr3_ck_n
  .c1_ddr3_ck_p                         (c1_ddr3_ck_p),            // output [0:0]        c1_ddr3_ck_p
  .c1_ddr3_cke                          (c1_ddr3_cke),             // output [0:0]        c1_ddr3_cke
  .c1_ddr3_ras_n                        (c1_ddr3_ras_n),           // output            c1_ddr3_ras_n
  .c1_ddr3_reset_n                      (c1_ddr3_reset_n),         // output            c1_ddr3_reset_n
  .c1_ddr3_we_n                         (c1_ddr3_we_n),            // output            c1_ddr3_we_n
  .c1_ddr3_dq                           (c1_ddr3_dq),              // inout [63:0]        c1_ddr3_dq
  .c1_ddr3_dqs_n                        (c1_ddr3_dqs_n),           // inout [7:0]        c1_ddr3_dqs_n
  .c1_ddr3_dqs_p                        (c1_ddr3_dqs_p),           // inout [7:0]        c1_ddr3_dqs_p
  .c1_init_calib_complete               (c1_init_calib_complete),  // output            init_calib_complete
    
  .c1_ddr3_cs_n                         (c1_ddr3_cs_n),            // output [0:0]        c1_ddr3_cs_n
  .c1_ddr3_odt                          (c1_ddr3_odt),             // output [:0]        c1_ddr3_odt
  // Application interface ports
  .c1_ui_clk                            (c1_ddr3_clk),               // output            c1_ui_clk
  .c1_ui_clk_sync_rst                   (c1_ddr3_rst),      // output            c1_ui_clk_sync_rst
  .c1_mmcm_locked                       (c1_mmcm_locked),          // output            c1_mmcm_locked
  .c1_aresetn                           (c1_ddr3_aresetn),            // input            c1_aresetn
  .c1_app_sr_req                        (0),                       // input            c1_app_sr_req
  .c1_app_ref_req                       (0),                       // input            c1_app_ref_req
  .c1_app_zq_req                        (0),                       // input            c1_app_zq_req
  .c1_app_sr_active                     (),        // output            c1_app_sr_active
  .c1_app_ref_ack                       (),          // output            c1_app_ref_ack
  .c1_app_zq_ack                        (),           // output            c1_app_zq_ack
  // Slave Interface Write Address Ports
  .c1_s_axi_awid                  (hbm_axi[1].awid),  
  .c1_s_axi_awaddr                (hbm_axi[1].awaddr),
  .c1_s_axi_awlen                 (hbm_axi[1].awlen),
  .c1_s_axi_awsize                (hbm_axi[1].awsize),
  .c1_s_axi_awburst               (hbm_axi[1].awburst),
  .c1_s_axi_awlock                (hbm_axi[1].awlock),
  .c1_s_axi_awcache               (hbm_axi[1].awcache),
  .c1_s_axi_awprot                (hbm_axi[1].awprot),
  .c1_s_axi_awqos                 (hbm_axi[1].awqos),
  .c1_s_axi_awvalid               (hbm_axi[1].awvalid),
  .c1_s_axi_awready               (hbm_axi[1].awready),

  // Slave Interface Write Data Ports
  .c1_s_axi_wdata                 (hbm_axi[1].wdata),
  .c1_s_axi_wstrb                 (hbm_axi[1].wstrb),
  .c1_s_axi_wlast                 (hbm_axi[1].wlast),
  .c1_s_axi_wvalid                (hbm_axi[1].wvalid),
  .c1_s_axi_wready                (hbm_axi[1].wready),
  // Slave Interface Write Response Ports
  .c1_s_axi_bid                   (hbm_axi[1].bid),
  .c1_s_axi_bresp                 (hbm_axi[1].bresp),
  .c1_s_axi_bvalid                (hbm_axi[1].bvalid),
  .c1_s_axi_bready                (hbm_axi[1].bready),
  // Slave Interface Read Address Ports
  .c1_s_axi_arid                  (hbm_axi[1].arid),
  .c1_s_axi_araddr                (hbm_axi[1].araddr),
  .c1_s_axi_arlen                 (hbm_axi[1].arlen),
  .c1_s_axi_arsize                (hbm_axi[1].arsize),
  .c1_s_axi_arburst               (hbm_axi[1].arburst),
  .c1_s_axi_arlock                (hbm_axi[1].arlock),
  .c1_s_axi_arcache               (hbm_axi[1].arcache),
  .c1_s_axi_arprot                (hbm_axi[1].arprot),
  .c1_s_axi_arqos                 (hbm_axi[1].arqos),
  .c1_s_axi_arvalid               (hbm_axi[1].arvalid),
  .c1_s_axi_arready               (hbm_axi[1].arready),
  // Slave Interface Read Data Ports
  .c1_s_axi_rid                   (hbm_axi[1].rid),
  .c1_s_axi_rdata                 (hbm_axi[1].rdata),
  .c1_s_axi_rresp                 (hbm_axi[1].rresp),
  .c1_s_axi_rlast                 (hbm_axi[1].rlast),
  .c1_s_axi_rvalid                (hbm_axi[1].rvalid),
  .c1_s_axi_rready                (hbm_axi[1].rready),
  // AXI CTRL port
  .c1_s_axi_ctrl_awvalid                (0),                       // input            c1_s_axi_ctrl_awvalid
  .c1_s_axi_ctrl_awready                (),   // output            c1_s_axi_ctrl_awready
  .c1_s_axi_ctrl_awaddr                 (0),                       // input [31:0]            c1_s_axi_ctrl_awaddr
  // Slave Interface Write Data Ports
  .c1_s_axi_ctrl_wvalid                 (0),                       // input            c1_s_axi_ctrl_wvalid
  .c1_s_axi_ctrl_wready                 (),    // output            c1_s_axi_ctrl_wready
  .c1_s_axi_ctrl_wdata                  (0),                       // input [31:0]            c1_s_axi_ctrl_wdata
  // Slave Interface Write Response Ports
  .c1_s_axi_ctrl_bvalid                 (),    // output            c1_s_axi_ctrl_bvalid
  .c1_s_axi_ctrl_bready                 (1),                       // input            c1_s_axi_ctrl_bready
  .c1_s_axi_ctrl_bresp                  (),     // output [1:0]            c1_s_axi_ctrl_bresp
  // Slave Interface Read Address Ports
  .c1_s_axi_ctrl_arvalid                (0),                       // input            c1_s_axi_ctrl_arvalid
  .c1_s_axi_ctrl_arready                (),   // output            c1_s_axi_ctrl_arready
  .c1_s_axi_ctrl_araddr                 (0),                       // input [31:0]            c1_s_axi_ctrl_araddr
  // Slave Interface Read Data Ports
  .c1_s_axi_ctrl_rvalid                 (),    // output            c1_s_axi_ctrl_rvalid
  .c1_s_axi_ctrl_rready                 (1),                       // input            c1_s_axi_ctrl_rready
  .c1_s_axi_ctrl_rdata                  (),     // output [31:0]            c1_s_axi_ctrl_rdata
  .c1_s_axi_ctrl_rresp                  (),     // output [1:0]            c1_s_axi_ctrl_rresp
  // Interrupt output
  .c1_interrupt                         (),                        // output            c1_interrupt
  .c1_app_ecc_multiple_err              (), // output [7:0]            c1_app_ecc_multiple_err
  // System Clock Ports
  .c1_sys_clk_p                         (c1_sys_clk_p),           // input                c1_sys_clk_p
  .c1_sys_clk_n                         (c1_sys_clk_n),           // input                c1_sys_clk_n
  .sys_rst                              (sys_rst_n_c & pok_dram)                     // input sys_rst
  );

  
  // wire                  c0_ddr4_clk;
  // wire                  c0_ddr4_rst;
  // reg                   c0_ddr4_aresetn;
  // wire                  c1_ddr4_clk;
  // wire                  c1_ddr4_rst;
  // reg                   c1_ddr4_aresetn;


  //  always @(posedge c0_ddr4_clk) begin      
  //    c0_ddr4_aresetn <= ~c0_ddr4_rst;       
  //  end                                      
                                              
                                              
  //  always @(posedge c1_ddr4_clk) begin      
  //    c1_ddr4_aresetn <= ~c1_ddr4_rst;       
  //  end                                      



 
   //  IBUFDS #(
   //    .IBUF_LOW_PWR("TRUE")     // Low power="TRUE", Highest performance="FALSE" 
   // ) IBUFDS0_inst (
   //    .O(ddr0_sys_100M),  // Buffer output
   //    .I(ddr0_sys_100M_p),  // Diff_p buffer input (connect directly to top-level port)
   //    .IB(ddr0_sys_100M_n) // Diff_n buffer input (connect directly to top-level port)
   // );
 
   
   //   BUFG BUFG0_inst (
   //    .O(DDR0_sys_clk), // 1-bit output: Clock output
   //    .I(ddr0_sys_100M)  // 1-bit input: Clock input
   // ); 
 
 
   //  IBUFDS #(
   //    .DIFF_TERM("FALSE"),       // Differential Termination
   //    .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
   //    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   // ) IBUFDS1_inst (
   //    .O(ddr1_sys_100M),  // Buffer output
   //    .I(ddr1_sys_100M_p),  // Diff_p buffer input (connect directly to top-level port)
   //    .IB(ddr1_sys_100M_n) // Diff_n buffer input (connect directly to top-level port)
   // );
 
   
   //   BUFG BUFG1_inst (
   //    .O(DDR1_sys_clk), // 1-bit output: Clock output
   //    .I(ddr1_sys_100M)  // 1-bit input: Clock input
   // );


       // assign hbm_axi[0].clk   = c0_ddr4_clk;
       // assign hbm_axi[1].clk   = c1_ddr4_clk;
       // assign hbm_axi[0].arstn = c0_ddr4_aresetn & (~hbm_reset);
       // assign hbm_axi[1].arstn = c1_ddr4_aresetn & (~hbm_reset);




   
   
// ddr4_0 u_ddr4_0
//   (
//    .sys_rst           (1'b0),

//    .c0_sys_clk_i                   (DDR0_sys_clk),
//    .c0_init_calib_complete (),
//    .c0_ddr4_act_n          (c0_ddr4_act_n),
//    .c0_ddr4_adr            (c0_ddr4_adr),
//    .c0_ddr4_ba             (c0_ddr4_ba),
//    .c0_ddr4_bg             (c0_ddr4_bg),
//    .c0_ddr4_cke            (c0_ddr4_cke),
//    .c0_ddr4_odt            (c0_ddr4_odt),
//    .c0_ddr4_cs_n           (c0_ddr4_cs_n),
//    .c0_ddr4_ck_t           (c0_ddr4_ck_t),
//    .c0_ddr4_ck_c           (c0_ddr4_ck_c),
//    .c0_ddr4_reset_n        (c0_ddr4_reset_n),

//      .c0_ddr4_parity                        (c0_ddr4_parity),
//    .c0_ddr4_dq             (c0_ddr4_dq),
//    .c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
//    .c0_ddr4_dqs_t          (c0_ddr4_dqs_t),

//    .c0_ddr4_ui_clk                (c0_ddr4_clk),
//    .c0_ddr4_ui_clk_sync_rst       (c0_ddr4_rst),
//    .addn_ui_clkout1                            (),
//    .dbg_clk                                    (),
//      // AXI CTRL port
//      .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
//      .c0_ddr4_s_axi_ctrl_awready       (),
//      .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
//      // Slave Interface Write Data Ports
//      .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
//      .c0_ddr4_s_axi_ctrl_wready        (),
//      .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
//      // Slave Interface Write Response Ports
//      .c0_ddr4_s_axi_ctrl_bvalid        (),
//      .c0_ddr4_s_axi_ctrl_bready        (1'b1),
//      .c0_ddr4_s_axi_ctrl_bresp         (),
//      // Slave Interface Read Address Ports
//      .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
//      .c0_ddr4_s_axi_ctrl_arready       (),
//      .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
//      // Slave Interface Read Data Ports
//      .c0_ddr4_s_axi_ctrl_rvalid        (),
//      .c0_ddr4_s_axi_ctrl_rready        (1'b1),
//      .c0_ddr4_s_axi_ctrl_rdata         (),
//      .c0_ddr4_s_axi_ctrl_rresp         (),
//      // Interrupt output
//      .c0_ddr4_interrupt                (),
//   // Slave Interface Write Address Ports
//   .c0_ddr4_aresetn                     (hbm_axi[0].arstn),
//   .c0_ddr4_s_axi_awid                  (hbm_axi[0].awid),
//   .c0_ddr4_s_axi_awaddr                (hbm_axi[0].awaddr),
//   .c0_ddr4_s_axi_awlen                 (hbm_axi[0].awlen),
//   .c0_ddr4_s_axi_awsize                (hbm_axi[0].awsize),
//   .c0_ddr4_s_axi_awburst               (hbm_axi[0].awburst),
//   .c0_ddr4_s_axi_awlock                (hbm_axi[0].awlock),
//   .c0_ddr4_s_axi_awcache               (hbm_axi[0].awcache),
//   .c0_ddr4_s_axi_awprot                (hbm_axi[0].awprot),
//   .c0_ddr4_s_axi_awqos                 (hbm_axi[0].awqos),
//   .c0_ddr4_s_axi_awvalid               (hbm_axi[0].awvalid),
//   .c0_ddr4_s_axi_awready               (hbm_axi[0].awready),
//   // Slave Interface Write Data Ports
//   .c0_ddr4_s_axi_wdata                 (hbm_axi[0].wdata),
//   .c0_ddr4_s_axi_wstrb                 (hbm_axi[0].wstrb),
//   .c0_ddr4_s_axi_wlast                 (hbm_axi[0].wlast),
//   .c0_ddr4_s_axi_wvalid                (hbm_axi[0].wvalid),
//   .c0_ddr4_s_axi_wready                (hbm_axi[0].wready),
//   // Slave Interface Write Response Ports
//   .c0_ddr4_s_axi_bid                   (hbm_axi[0].bid),
//   .c0_ddr4_s_axi_bresp                 (hbm_axi[0].bresp),
//   .c0_ddr4_s_axi_bvalid                (hbm_axi[0].bvalid),
//   .c0_ddr4_s_axi_bready                (hbm_axi[0].bready),
//   // Slave Interface Read Address Ports
//   .c0_ddr4_s_axi_arid                  (hbm_axi[0].arid),
//   .c0_ddr4_s_axi_araddr                (hbm_axi[0].araddr),
//   .c0_ddr4_s_axi_arlen                 (hbm_axi[0].arlen),
//   .c0_ddr4_s_axi_arsize                (hbm_axi[0].arsize),
//   .c0_ddr4_s_axi_arburst               (hbm_axi[0].arburst),
//   .c0_ddr4_s_axi_arlock                (hbm_axi[0].arlock),
//   .c0_ddr4_s_axi_arcache               (hbm_axi[0].arcache),
//   .c0_ddr4_s_axi_arprot                (hbm_axi[0].arprot),
//   .c0_ddr4_s_axi_arqos                 (hbm_axi[0].arqos),
//   .c0_ddr4_s_axi_arvalid               (hbm_axi[0].arvalid),
//   .c0_ddr4_s_axi_arready               (hbm_axi[0].arready),
//   // Slave Interface Read Data Ports
//   .c0_ddr4_s_axi_rid                   (hbm_axi[0].rid),
//   .c0_ddr4_s_axi_rdata                 (hbm_axi[0].rdata),
//   .c0_ddr4_s_axi_rresp                 (hbm_axi[0].rresp),
//   .c0_ddr4_s_axi_rlast                 (hbm_axi[0].rlast),
//   .c0_ddr4_s_axi_rvalid                (hbm_axi[0].rvalid),
//   .c0_ddr4_s_axi_rready                (hbm_axi[0].rready),
  
//   // Debug Port
//   .dbg_bus         ()                                             

//   ); 




// ddr4_1 u_ddr4_1
//   (
//    .sys_rst           (1'b0),

//    .c0_sys_clk_i                   (DDR1_sys_clk),
//    .c0_init_calib_complete (),
//    .c0_ddr4_act_n          (c1_ddr4_act_n),
//    .c0_ddr4_adr            (c1_ddr4_adr),
//    .c0_ddr4_ba             (c1_ddr4_ba),
//    .c0_ddr4_bg             (c1_ddr4_bg),
//    .c0_ddr4_cke            (c1_ddr4_cke),
//    .c0_ddr4_odt            (c1_ddr4_odt),
//    .c0_ddr4_cs_n           (c1_ddr4_cs_n),
//    .c0_ddr4_ck_t           (c1_ddr4_ck_t),
//    .c0_ddr4_ck_c           (c1_ddr4_ck_c),
//    .c0_ddr4_reset_n        (c1_ddr4_reset_n),

//      .c0_ddr4_parity                        (c1_ddr4_parity),
//    .c0_ddr4_dq             (c1_ddr4_dq),
//    .c0_ddr4_dqs_c          (c1_ddr4_dqs_c),
//    .c0_ddr4_dqs_t          (c1_ddr4_dqs_t),

//    .c0_ddr4_ui_clk                (c1_ddr4_clk),
//    .c0_ddr4_ui_clk_sync_rst       (c1_ddr4_rst),
//    .addn_ui_clkout1                            (),
//    .dbg_clk                                    (),
//      // AXI CTRL port
//      .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
//      .c0_ddr4_s_axi_ctrl_awready       (),
//      .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
//      // Slave Interface Write Data Ports
//      .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
//      .c0_ddr4_s_axi_ctrl_wready        (),
//      .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
//      // Slave Interface Write Response Ports
//      .c0_ddr4_s_axi_ctrl_bvalid        (),
//      .c0_ddr4_s_axi_ctrl_bready        (1'b1),
//      .c0_ddr4_s_axi_ctrl_bresp         (),
//      // Slave Interface Read Address Ports
//      .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
//      .c0_ddr4_s_axi_ctrl_arready       (),
//      .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
//      // Slave Interface Read Data Ports
//      .c0_ddr4_s_axi_ctrl_rvalid        (),
//      .c0_ddr4_s_axi_ctrl_rready        (1'b1),
//      .c0_ddr4_s_axi_ctrl_rdata         (),
//      .c0_ddr4_s_axi_ctrl_rresp         (),
//      // Interrupt output
//      .c0_ddr4_interrupt                (),
//   // Slave Interface Write Address Ports
//   .c0_ddr4_aresetn                     (hbm_axi[1].arstn),
//   .c0_ddr4_s_axi_awid                  (hbm_axi[1].awid),
//   .c0_ddr4_s_axi_awaddr                (hbm_axi[1].awaddr),
//   .c0_ddr4_s_axi_awlen                 (hbm_axi[1].awlen),
//   .c0_ddr4_s_axi_awsize                (hbm_axi[1].awsize),
//   .c0_ddr4_s_axi_awburst               (hbm_axi[1].awburst),
//   .c0_ddr4_s_axi_awlock                (hbm_axi[1].awlock),
//   .c0_ddr4_s_axi_awcache               (hbm_axi[1].awcache),
//   .c0_ddr4_s_axi_awprot                (hbm_axi[1].awprot),
//   .c0_ddr4_s_axi_awqos                 (hbm_axi[1].awqos),
//   .c0_ddr4_s_axi_awvalid               (hbm_axi[1].awvalid),
//   .c0_ddr4_s_axi_awready               (hbm_axi[1].awready),
//   // Slave Interface Write Data Ports           
//   .c0_ddr4_s_axi_wdata                 (hbm_axi[1].wdata),
//   .c0_ddr4_s_axi_wstrb                 (hbm_axi[1].wstrb),
//   .c0_ddr4_s_axi_wlast                 (hbm_axi[1].wlast),
//   .c0_ddr4_s_axi_wvalid                (hbm_axi[1].wvalid),
//   .c0_ddr4_s_axi_wready                (hbm_axi[1].wready),
//   // Slave Interface Write Response Ports       
//   .c0_ddr4_s_axi_bid                   (hbm_axi[1].bid),
//   .c0_ddr4_s_axi_bresp                 (hbm_axi[1].bresp),
//   .c0_ddr4_s_axi_bvalid                (hbm_axi[1].bvalid),
//   .c0_ddr4_s_axi_bready                (hbm_axi[1].bready),
//   // Slave Interface Read Address Ports
//   .c0_ddr4_s_axi_arid                  (hbm_axi[1].arid),
//   .c0_ddr4_s_axi_araddr                (hbm_axi[1].araddr),
//   .c0_ddr4_s_axi_arlen                 (hbm_axi[1].arlen),
//   .c0_ddr4_s_axi_arsize                (hbm_axi[1].arsize),
//   .c0_ddr4_s_axi_arburst               (hbm_axi[1].arburst),
//   .c0_ddr4_s_axi_arlock                (hbm_axi[1].arlock),
//   .c0_ddr4_s_axi_arcache               (hbm_axi[1].arcache),
//   .c0_ddr4_s_axi_arprot                (hbm_axi[1].arprot),
//   .c0_ddr4_s_axi_arqos                 (hbm_axi[1].arqos),
//   .c0_ddr4_s_axi_arvalid               (hbm_axi[1].arvalid),
//   .c0_ddr4_s_axi_arready               (hbm_axi[1].arready),
//   // Slave Interface Read Data Ports
//   .c0_ddr4_s_axi_rid                   (hbm_axi[1].rid),
//   .c0_ddr4_s_axi_rdata                 (hbm_axi[1].rdata),
//   .c0_ddr4_s_axi_rresp                 (hbm_axi[1].rresp),
//   .c0_ddr4_s_axi_rlast                 (hbm_axi[1].rlast),
//   .c0_ddr4_s_axi_rvalid                (hbm_axi[1].rvalid),
//   .c0_ddr4_s_axi_rready                (hbm_axi[1].rready),
  
//   // Debug Port
//   .dbg_bus         ()                                             

//   ); 












endmodule