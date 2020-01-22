`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/18 14:10:37
// Design Name: 
// Module Name: xdma_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module xdma_control#(
	parameter N_MEM_INTF			      = 32,
  parameter N_ULTRARAM_INTF       = 2,
  parameter ULTRARAM_NUM_WIDTH    = 0
)
(
  input  wire         s_aclk,
  input  wire         s_aresetn,
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

///////////hbm——test——reg
    input  [N_ULTRARAM_INTF-1:0]         hbm_axi_clk,
    output reg                           hbm_reset,
    output reg       [ 31:0]             work_group_size,
    output reg       [ 31:0]             stride,
    output reg       [ 63:0]             num_mem_ops,
    output reg       [ 31:0]             mem_burst_size,
    output reg       [ 63:0]             initial_addr,
    output reg       [  7:0]             hbm_channel,
    output reg [N_MEM_INTF-1:0]          write_enable,
    output reg [N_MEM_INTF-1:0]          read_enable,
    output reg                           latency_test_enable,
    output reg                           start,

    input  [N_MEM_INTF-1:0]             end_wr,
    input  [N_MEM_INTF-1:0]             end_rd,
    input         [ 31:0]               lat_timer_sum_wr,
    input         [ 31:0]               lat_timer_sum_rd,
	input  [N_ULTRARAM_INTF-1:0]        lat_timer_valid , //log down lat_timer when lat_timer_valid is 1. 
    input  [N_ULTRARAM_INTF-1:0][15:0]  lat_timer
      
    );


    localparam[2:0]                    WIDLE = 3'b001;
    localparam[2:0]                    WDATA = 3'b010;
    localparam[2:0]                    WBRSP = 3'b100;
    localparam[2:0]                    RIDLE = 3'b001;
    localparam[2:0]                    RDATA = 3'b010;
    localparam[2:0]                    RWAIT = 3'b100;

    reg [63:0][31:0]                  dma_control_reg;
    
    reg [2:0]                         w_nstate;
    reg [2:0]                         w_cstate;
    reg [2:0]                         r_nstate;
    reg [2:0]                         r_cstate;

    reg [5:0]                         wr_addr;
    reg [31:0]                        wr_data;

    reg [5:0]                         rd_addr;

    // reg [N_ULTRARAM_INTF-1:0][19-ULTRARAM_NUM_WIDTH:0]				addra;
    // reg [N_ULTRARAM_INTF-1:0][19-ULTRARAM_NUM_WIDTH:0]				addrb;
    reg [19:0]                        addra_ori;
    reg [19:0]                        addrb_ori;

    wire[7:0]				                    doutb;
    reg [7:0]                           doutb_r;
    reg [7:0]                             lat_timer_out;                                  
    reg                                     ram_wr_en,ram_wr_en_r;

  always @(posedge s_aclk)begin
    hbm_reset                    <= dma_control_reg[ 0][0];
    work_group_size              <= dma_control_reg[ 1];
    stride                       <= dma_control_reg[ 2];
    num_mem_ops[31: 0]           <= dma_control_reg[ 3];
    num_mem_ops[63:32]           <= dma_control_reg[ 4];
    mem_burst_size               <= dma_control_reg[ 5];
    initial_addr[31: 0]          <= dma_control_reg[ 6];
    initial_addr[63:32]          <= dma_control_reg[17];
    write_enable                 <= dma_control_reg[7];
    read_enable                  <= dma_control_reg[8];
    latency_test_enable          <= dma_control_reg[9][0];
    hbm_channel                  <= dma_control_reg[10][7:0];
    start                        <= dma_control_reg[11][0];
  end


    
    assign s_axil_awready               = w_cstate[0];
    assign s_axil_wready                = w_cstate[1];
    assign s_axil_bresp                 = 0;
    assign s_axil_bvalid                = w_cstate[2];
    assign s_axil_arready               = r_cstate[0];
    assign s_axil_rdata                 = dma_control_reg[rd_addr];
    assign s_axil_rresp                 = 0;
    assign s_axil_rvalid                = r_cstate[1];
      
    
     
    
    



    
    always @(posedge s_aclk)begin
      if(~s_aresetn)begin
        dma_control_reg[ 0]             <= 0;
        dma_control_reg[ 1]             <= 32'h1000_0000;
        dma_control_reg[ 2]             <= 32'h40;
        dma_control_reg[ 3]             <= 32'h1000;
        dma_control_reg[ 4]             <= 0;
        dma_control_reg[ 5]             <= 0;
        dma_control_reg[ 6]             <= 32'h0;
        dma_control_reg[ 7]             <= 32'h0;
        dma_control_reg[ 8]             <= 32'h0;
        dma_control_reg[ 9]             <= 32'h0;
        dma_control_reg[10]             <= 32'h0;
        dma_control_reg[11]             <= 32'h0;
        dma_control_reg[17]             <= 32'h0;
      end
      else if(w_cstate == WBRSP)begin
        dma_control_reg[wr_addr]        <= wr_data;
      end
      else begin
        dma_control_reg[12]             <= end_wr;
        dma_control_reg[13]             <= end_rd;
        dma_control_reg[14]             <= lat_timer_sum_wr;
        dma_control_reg[15]             <= lat_timer_sum_rd;
		    dma_control_reg[16]             <= {24'b0,lat_timer_out};
      end

    end






    always@(posedge s_aclk)begin
      if(~s_aresetn)
        w_cstate                        <= WIDLE;
      else
        w_cstate                        <= w_nstate;
    end

    always@(*)begin
      w_nstate                          = WIDLE;
      case(w_cstate)
        WIDLE:begin
          if(s_axil_awvalid & s_axil_awready)begin
            wr_addr                     = s_axil_awaddr[7:2];
            w_nstate                    = WDATA;
          end
          else
            w_nstate                    = WIDLE;
        end
        WDATA:begin
          if(s_axil_wvalid & s_axil_wready)begin
            wr_data                     = s_axil_wdata;
            w_nstate                    = WBRSP;
          end
          else
            w_nstate                    = WDATA;
        end
        WBRSP:begin
          if(s_axil_bvalid & s_axil_bready)
            w_nstate                    = WIDLE;
          else
            w_nstate                    = WBRSP;
        end
        default:begin
          w_nstate                    = WIDLE;
        end
      endcase
    end



//////////////////////////////////////////////////////////


    reg [3:0] counter;

    always@(posedge s_aclk)begin
      if(~s_aresetn)
        counter       <= 4'b0;
      else if(r_cstate == RWAIT)
        counter       <= counter +1;
      else
        counter       <= 4'b0;
    end


    always@(posedge s_aclk)begin
      if(~s_aresetn)
        r_cstate                        <= RIDLE;
      else
        r_cstate                        <= r_nstate;
    end

    always@(*)begin
      r_nstate                          = WIDLE;
      case(r_cstate)
        RIDLE:begin
          if(s_axil_arvalid & s_axil_arready)begin
            rd_addr                     = s_axil_araddr[7:2];
            r_nstate                    = RDATA;
          end
          else
            r_nstate                    = RIDLE;
        end
        RDATA:begin
          if(s_axil_rvalid & s_axil_rready)begin
            r_nstate                    = RWAIT;
          end
          else
            r_nstate                    = RDATA;
        end
        RWAIT:begin
          if(counter == 4'b1111)begin
            r_nstate                    = RIDLE;
          end
          else
            r_nstate                    = RWAIT;
        end
        default:begin
          r_nstate                    = RIDLE;
        end
      endcase
    end






// XPM_MEMORY instantiation template for True Dual Port RAM configurations
// Refer to the targeted device family architecture libraries guide for XPM_MEMORY documentation
// =======================================================================================================================

// Parameter usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Parameter name       | Data type          | Restrictions, if applicable                                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | ADDR_WIDTH_A         | Integer            | Range: 1 - 20. Default value = 6.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port A address port addra, in bits.                                                        |
// | Must be large enough to access the entire memory from port A, i.e. = $clog2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_A). |
// +---------------------------------------------------------------------------------------------------------------------+
// | ADDR_WIDTH_B         | Integer            | Range: 1 - 20. Default value = 6.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port B address port addrb, in bits.                                                        |
// | Must be large enough to access the entire memory from port B, i.e. = $clog2(MEMORY_SIZE/[WRITE|READ]_DATA_WIDTH_B). |
// +---------------------------------------------------------------------------------------------------------------------+
// | AUTO_SLEEP_TIME      | Integer            | Range: 0 - 15. Default value = 0.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Number of clk[a|b] cycles to auto-sleep, if feature is available in architecture                                    |
// | 0 - Disable auto-sleep feature                                                                                      |
// | 3-15 - Number of auto-sleep latency cycles                                                                          |
// | Do not change from the value provided in the template instantiation                                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | BYTE_WRITE_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | To enable byte-wide writes on port A, specify the byte width, in bits-                                              |
// | 8- 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 8                                |
// | 9- 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 9                                |
// | Or to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | BYTE_WRITE_WIDTH_B   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | To enable byte-wide writes on port B, specify the byte width, in bits-                                              |
// | 8- 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_B is an integer multiple of 8                                |
// | 9- 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_B is an integer multiple of 9                                |
// | Or to enable word-wide writes on port B, specify the same value as for WRITE_DATA_WIDTH_B.                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | 0- No Cascade Height, Allow Vivado Synthesis to choose.                                                             |
// | 1 or more - Vivado Synthesis sets the specified value as Cascade Height.                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | CLOCKING_MODE        | String             | Allowed values: common_clock, independent_clock. Default value = common_clock.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Designate whether port A and port B are clocked with a common clock or with independent clocks-                     |
// | "common_clock"- Common clocking; clock both port A and port B with clka                                             |
// | "independent_clock"- Independent clocking; clock port A with clka and port B with clkb                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | ECC_MODE             | String             | Allowed values: no_ecc, both_encode_and_decode, decode_only, encode_only. Default value = no_ecc.|
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "no_ecc" - Disables ECC                                                                                           |
// |   "encode_only" - Enables ECC Encoder only                                                                          |
// |   "decode_only" - Enables ECC Decoder only                                                                          |
// |   "both_encode_and_decode" - Enables both ECC Encoder and Decoder                                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_INIT_FILE     | String             | Default value = none.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "none" (including quotes) for no memory initialization, or specify the name of a memory initialization file-|
// | Enter only the name of the file with .mem extension, including quotes but without path (e.g. "my_file.mem").        |
// | File format must be ASCII and consist of only hexadecimal values organized into the specified depth by              |
// | narrowest data width generic value of the memory. See the Memory File (MEM) section for more                        |
// | information on the syntax. Initialization of memory happens through the file name specified only when parameter     |
// | MEMORY_INIT_PARAM value is equal to "".                                                                           | |
// | When using XPM_MEMORY in a project, add the specified file to the Vivado project as a design source.                |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_INIT_PARAM    | String             | Default value = 0.                                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "" or "0" (including quotes) for no memory initialization through parameter, or specify the string          |
// | containing the hex characters. Enter only hex characters with each location separated by delimiter (,).             |
// | Parameter format must be ASCII and consist of only hexadecimal values organized into the specified depth by         |
// | narrowest data width generic value of the memory.For example, if the narrowest data width is 8, and the depth of    |
// | memory is 8 locations, then the parameter value should be passed as shown below.                                    |
// | parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"                                                               |
// | Where "AB" is the 0th location and "78" is the 7th location.                                                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_OPTIMIZATION  | String             | Allowed values: true, false. Default value = true.                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "true" to enable the optimization of unused memory or bits in the memory structure. Specify "false" to      |
// | disable the optimization of unused memory or bits in the memory structure.                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_PRIMITIVE     | String             | Allowed values: auto, block, distributed, ultra. Default value = auto.  |
// |---------------------------------------------------------------------------------------------------------------------|
// | Designate the memory primitive (resource type) to use-                                                              |
// | "auto"- Allow Vivado Synthesis to choose                                                                            |
// | "distributed"- Distributed memory                                                                                   |
// | "block"- Block memory                                                                                               |
// | "ultra"- Ultra RAM memory                                                                                           |
// | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with MEMORY_PRIMITIVE set to "auto".|
// +---------------------------------------------------------------------------------------------------------------------+
// | MEMORY_SIZE          | Integer            | Range: 2 - 150994944. Default value = 2048.                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the total memory array size, in bits.                                                                       |
// | For example, enter 65536 for a 2kx32 RAM.                                                                           |
// | When ECC is enabled and set to "encode_only", then the memory size has to be multiples of READ_DATA_WIDTH_[A|B]     |
// | When ECC is enabled and set to "decode_only", then the memory size has to be multiples of WRITE_DATA_WIDTH_[A|B].   |
// +---------------------------------------------------------------------------------------------------------------------+
// | MESSAGE_CONTROL      | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify 1 to enable the dynamic message reporting such as collision warnings, and 0 to disable the message reporting|
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_DATA_WIDTH_A    | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port A read data output port douta, in bits.                                               |
// | The values of READ_DATA_WIDTH_A and WRITE_DATA_WIDTH_A must be equal.                                               |
// | When ECC is enabled and set to "encode_only", then READ_DATA_WIDTH_A has to be multiples of 72-bits                 |
// | When ECC is enabled and set to "decode_only" or "both_encode_and_decode", then READ_DATA_WIDTH_A has to be          |
// | multiples of 64-bits.                                                                                               |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_DATA_WIDTH_B    | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port B read data output port doutb, in bits.                                               |
// | The values of READ_DATA_WIDTH_B and WRITE_DATA_WIDTH_B must be equal.                                               |
// | When ECC is enabled and set to "encode_only", then READ_DATA_WIDTH_B has to be multiples of 72-bits                 |
// | When ECC is enabled and set to "decode_only" or "both_encode_and_decode", then READ_DATA_WIDTH_B has to be          |
// | multiples of 64-bits.                                                                                               |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_LATENCY_A       | Integer            | Range: 0 - 100. Default value = 2.                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the number of register stages in the port A read data pipeline. Read data output to port douta takes this   |
// | number of clka cycles.                                                                                              |
// | To target block memory, a value of 1 or larger is required- 1 causes use of memory latch only; 2 causes use of      |
// | output register. To target distributed memory, a value of 0 or larger is required- 0 indicates combinatorial output.|
// | Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_LATENCY_B       | Integer            | Range: 0 - 100. Default value = 2.                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the number of register stages in the port B read data pipeline. Read data output to port doutb takes this   |
// | number of clkb cycles (clka when CLOCKING_MODE is "common_clock").                                                  |
// | To target block memory, a value of 1 or larger is required- 1 causes use of memory latch only; 2 causes use of      |
// | output register. To target distributed memory, a value of 0 or larger is required- 0 indicates combinatorial output.|
// | Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_RESET_VALUE_A   | String             | Default value = 0.                                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the reset value of the port A final output register stage in response to rsta input port is assertion.      |
// | As this parameter is a string, please specify the hex values inside double quotes. As an example,                   |
// | If the read data width is 8, then specify READ_RESET_VALUE_A = "EA";                                                |
// | When ECC is enabled, then reset value is not supported.                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_RESET_VALUE_B   | String             | Default value = 0.                                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the reset value of the port B final output register stage in response to rstb input port is assertion.      |
// | As this parameter is a string, please specify the hex values inside double quotes. As an example,                   |
// | If the read data width is 8, then specify READ_RESET_VALUE_B = "EA";                                                |
// | When ECC is enabled, then reset value is not supported.                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | RST_MODE_A           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Describes the behaviour of the reset                                                                                |
// |                                                                                                                     |
// |   "SYNC" - when reset is applied, synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A|
// |   "ASYNC" - when reset is applied, asynchronously resets output port douta to zero                                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | RST_MODE_B           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Describes the behaviour of the reset                                                                                |
// |                                                                                                                     |
// |   "SYNC" - when reset is applied, synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B|
// |   "ASYNC" - when reset is applied, asynchronously resets output port doutb to zero                                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
// | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_EMBEDDED_CONSTRAINT| Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify 1 to enable the set_false_path constraint addition between clka of Distributed RAM and doutb_reg on clkb    |
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_MEM_INIT         | Integer            | Range: 0 - 1. Default value = 1.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify 1 to enable the generation of below message and 0 to disable generation of the following message completely.|
// | "INFO - MEMORY_INIT_FILE and MEMORY_INIT_PARAM together specifies no memory initialization.                         |
// | Initial memory contents will be all 0s."                                                                            |
// | NOTE: This message gets generated only when there is no Memory Initialization specified either through file or      |
// | Parameter.                                                                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | WAKEUP_TIME          | String             | Allowed values: disable_sleep, use_sleep_pin. Default value = disable_sleep.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify "disable_sleep" to disable dynamic power saving option, and specify "use_sleep_pin" to enable the           |
// | dynamic power saving option                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_DATA_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port A write data input port dina, in bits.                                                |
// | The values of WRITE_DATA_WIDTH_A and READ_DATA_WIDTH_A must be equal.                                               |
// | When ECC is enabled and set to "encode_only" or "both_encode_and_decode", then WRITE_DATA_WIDTH_A has to be         |
// | multiples of 64-bits                                                                                                |
// | When ECC is enabled and set to "decode_only", then WRITE_DATA_WIDTH_A has to be multiples of 72-bits.               |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_DATA_WIDTH_B   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specify the width of the port B write data input port dinb, in bits.                                                |
// | The values of WRITE_DATA_WIDTH_B and READ_DATA_WIDTH_B must be equal.                                               |
// | When ECC is enabled and set to "encode_only" or "both_encode_and_decode", then WRITE_DATA_WIDTH_B has to be         |
// | multiples of 64-bits                                                                                                |
// | When ECC is enabled and set to "decode_only", then WRITE_DATA_WIDTH_B has to be multiples of 72-bits.               |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_MODE_A         | String             | Allowed values: no_change, read_first, write_first. Default value = no_change.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Write mode behavior for port A output data port, douta.                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_MODE_B         | String             | Allowed values: no_change, read_first, write_first. Default value = no_change.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Write mode behavior for port B output data port, doutb.                                                             |
// +---------------------------------------------------------------------------------------------------------------------+

// Port usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | addra          | Input     | ADDR_WIDTH_A                          | clka    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Address for port A write and read operations.                                                                       |
// +---------------------------------------------------------------------------------------------------------------------+
// | addrb          | Input     | ADDR_WIDTH_B                          | clkb    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Address for port B write and read operations.                                                                       |
// +---------------------------------------------------------------------------------------------------------------------+
// | clka           | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | clkb           | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Clock signal for port B when parameter CLOCKING_MODE is "independent_clock".                                        |
// | Unused when parameter CLOCKING_MODE is "common_clock".                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | dbiterra       | Output    | 1                                     | clka    | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Status signal to indicate double bit error occurrence on the data output of port A.                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | dbiterrb       | Output    | 1                                     | clkb    | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Status signal to indicate double bit error occurrence on the data output of port A.                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | dina           | Input     | WRITE_DATA_WIDTH_A                    | clka    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Data input for port A write operations.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | dinb           | Input     | WRITE_DATA_WIDTH_B                    | clkb    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Data input for port B write operations.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | douta          | Output    | READ_DATA_WIDTH_A                     | clka    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Data output for port A read operations.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | doutb          | Output    | READ_DATA_WIDTH_B                     | clkb    | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Data output for port B read operations.                                                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | ena            | Input     | 1                                     | clka    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Memory enable signal for port A.                                                                                    |
// | Must be high on clock cycles when read or write operations are initiated. Pipelined internally.                     |
// +---------------------------------------------------------------------------------------------------------------------+
// | enb            | Input     | 1                                     | clkb    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Memory enable signal for port B.                                                                                    |
// | Must be high on clock cycles when read or write operations are initiated. Pipelined internally.                     |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectdbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in  |
// | "decode_only" mode).                                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectdbiterrb | Input     | 1                                     | clkb    | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in  |
// | "decode_only" mode).                                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectsbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in  |
// | "decode_only" mode).                                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectsbiterrb | Input     | 1                                     | clkb    | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in  |
// | "decode_only" mode).                                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | regcea         | Input     | 1                                     | clka    | Active-high | Tie to 1'b1            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Clock Enable for the last register stage on the output data path.                                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | regceb         | Input     | 1                                     | clkb    | Active-high | Tie to 1'b1            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Clock Enable for the last register stage on the output data path.                                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | rsta           | Input     | 1                                     | clka    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Reset signal for the final port A output register stage.                                                            |
// | Synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | rstb           | Input     | 1                                     | clkb    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Reset signal for the final port B output register stage.                                                            |
// | Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | sbiterra       | Output    | 1                                     | clka    | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Status signal to indicate single bit error occurrence on the data output of port A.                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | sbiterrb       | Output    | 1                                     | clkb    | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Status signal to indicate single bit error occurrence on the data output of port B.                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | sleep signal to enable the dynamic power saving feature.                                                            |
// +---------------------------------------------------------------------------------------------------------------------+
// | wea            | Input     | WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A | clka    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used.                     |
// | In byte-wide write configurations, each bit controls the writing one byte of dina to address addra.                 |
// | For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.   |
// +---------------------------------------------------------------------------------------------------------------------+
// | web            | Input     | WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B | clkb    | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write enable vector for port B input data port dinb. 1 bit wide when word-wide writes are used.                     |
// | In byte-wide write configurations, each bit controls the writing one byte of dinb to address addrb.                 |
// | For example, to synchronously write only bits [15-8] of dinb when WRITE_DATA_WIDTH_B is 32, web would be 4'b0010.   |
// +---------------------------------------------------------------------------------------------------------------------+


// xpm_memory_tdpram : In order to incorporate this function into the design,
//      Verilog      : the following instance declaration needs to be placed
//     instance      : in the body of the design code.  The instance name
//    declaration    : (xpm_memory_tdpram_inst) and/or the port declarations within the
//       code        : parenthesis may be changed to properly reference and
//                   : connect this function to the design.  All inputs
//                   : and outputs must be connected.

//  Please reference the appropriate libraries guide for additional information on the XPM modules.


  wire [N_ULTRARAM_INTF-1:0][15:0]                     fifo_data_out;
  reg [7:0]                       ram_data_in;
  // reg [N_ULTRARAM_INTF-1:0][7:0]  ram_data_in_r;
  // reg [ULTRARAM_NUM_WIDTH-1:0]    ram_choice;
  wire [N_ULTRARAM_INTF-1:0]                           fifo_empty;
  wire [N_ULTRARAM_INTF-1:0]                           fifo_rd_en;
  reg  [N_ULTRARAM_INTF-1:0]                           fifo_rd_en_r;


	always@(posedge s_aclk)begin
		if(~s_aresetn || hbm_reset || start)begin
			addra_ori					    <= 0;
		end
		else if(fifo_rd_en_r[hbm_channel])begin
			addra_ori   					<= addra_ori + 1'b1;
		end
		else begin
			addra_ori   					<= addra_ori;
		end
	end


	always@(posedge s_aclk)begin
		if(~s_aresetn || hbm_reset || start)begin
			addrb_ori   					<= 0;
		end
		else if((rd_addr == 16)&s_axil_rvalid & s_axil_rready)begin
			addrb_ori   					<= addrb_ori + 1'b1;
		end
		else begin
			addrb_ori   					<= addrb_ori;
		end
	end



  // always@(posedge s_aclk)begin
  //   if(~s_aresetn)
  //     fifo_rd_en                <= 1'b0;
  //   else if(~fifo_empty)
  //     fifo_rd_en                <= 1'b1;
  //   else
  //     fifo_rd_en                <= 1'b0;
  // end
 genvar i;
 // Instantiate engines
 generate
 for(i = 0; i < N_ULTRARAM_INTF; i++) 
 begin
  assign fifo_rd_en[i] = ~fifo_empty[i];

  always @(posedge s_aclk)begin
    fifo_rd_en_r[i]                      <= fifo_rd_en[i];
  end

  reg[N_ULTRARAM_INTF-1:0][15:0] lat_timer_i;
  reg[N_ULTRARAM_INTF-1:0]       lat_timer_valid_i;
  always @(posedge hbm_axi_clk[i])begin
    lat_timer_i[i]                       <= lat_timer[i];
    lat_timer_valid_i[i]                 <= lat_timer_valid[i];
  end

w16_d512_fwft_fifo lat_time_pri_fifo (
  .srst(~s_aresetn),                // input wire srst
  .wr_clk(hbm_axi_clk[i]),            // input wire wr_clk
  .rd_clk(s_aclk),            // input wire rd_clk
  .din(lat_timer_i[i]),                  // input wire [15 : 0] din
  .wr_en(lat_timer_valid_i[i]),              // input wire wr_en
  .rd_en(fifo_rd_en[i]),              // input wire rd_en
  .dout(fifo_data_out[i]),                // output wire [15 : 0] dout
  .full(),                // output wire full
  .empty(fifo_empty[i]),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

 end
 endgenerate


  // always @(posedge s_aclk)begin
  //   ram_choice                      <= addrb_ori[19:20-ULTRARAM_NUM_WIDTH];
  // end

  always @(posedge s_aclk)begin
    if(~s_aresetn)begin
      lat_timer_out                 <= 8'b0;
    end
    else begin
      lat_timer_out                 <= doutb;
    end
  end







//generate end generate
// genvar i;
// // Instantiate engines
// generate
// for(i = 0; i < N_ULTRARAM_INTF; i++) 
// begin

//  <-----Cut code below this line---->

   // xpm_memory_tdpram: True Dual Port RAM
   // Xilinx Parameterized Macro, version 2019.2

  // always @(posedge s_aclk)begin
  //   addra[i]                      <= addra_ori[19-ULTRARAM_NUM_WIDTH:0];
  // end

  // always @(posedge s_aclk)begin
  //   addrb[i]                      <= addrb_ori[19-ULTRARAM_NUM_WIDTH:0];
  // end

  always @(posedge s_aclk)begin
    if(~s_aresetn)begin
      ram_wr_en               <= 1'b0;
    end
    else begin
      ram_wr_en                <= fifo_rd_en[hbm_channel];
    end                  
  end

  always @(posedge s_aclk)begin
        ram_data_in                   <= fifo_data_out[hbm_channel][7:0];
  end


  // always @(posedge s_aclk)begin
  //   ram_data_in_r[i]                 <= ram_data_in;
  // end  

  // always @(posedge s_aclk)begin
  //   ram_wr_en_r[i]                   <= ram_wr_en[i];
  // end


  // always @(posedge s_aclk)begin
  //   doutb_r[i]                   <= doutb[i];
  // end

   xpm_memory_tdpram #(
      .ADDR_WIDTH_A(20),               // DECIMAL
      .ADDR_WIDTH_B(20),               // DECIMAL
      .AUTO_SLEEP_TIME(0),            // DECIMAL
      .BYTE_WRITE_WIDTH_A(8),        // DECIMAL
      .BYTE_WRITE_WIDTH_B(8),        // DECIMAL
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .MEMORY_INIT_FILE("none"),      // String
      .MEMORY_INIT_PARAM("0"),        // String
      .MEMORY_OPTIMIZATION("true"),   // String
      .MEMORY_PRIMITIVE("ultra"),      // String
      .MEMORY_SIZE(8388608),             // DECIMAL
      .MESSAGE_CONTROL(0),            // DECIMAL
      .READ_DATA_WIDTH_A(8),         // DECIMAL
      .READ_DATA_WIDTH_B(8),         // DECIMAL
      .READ_LATENCY_A(17),             // DECIMAL
      .READ_LATENCY_B(17),             // DECIMAL
      .READ_RESET_VALUE_A("0"),       // String
      .READ_RESET_VALUE_B("0"),       // String
      .RST_MODE_A("SYNC"),            // String
      .RST_MODE_B("SYNC"),            // String
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
      .USE_MEM_INIT(1),               // DECIMAL
      .WAKEUP_TIME("disable_sleep"),  // String
      .WRITE_DATA_WIDTH_A(8),        // DECIMAL
      .WRITE_DATA_WIDTH_B(8),        // DECIMAL
      .WRITE_MODE_A("no_change"),     // String
      .WRITE_MODE_B("no_change")      // String
   )
   xpm_memory_tdpram_inst (
      .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence
                                       // on the data output of port A.

      .dbiterrb(),             // 1-bit output: Status signal to indicate double bit error occurrence
                                       // on the data output of port A.
            
      .douta(),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      .doutb(doutb),                   // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
      .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                       // on the data output of port A.

      .sbiterrb(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                       // on the data output of port B.

      .addra(addra_ori),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
      .addrb(addrb_ori),                   // ADDR_WIDTH_B-bit input: Address for port B write and read operations.
      .clka(s_aclk),                     // 1-bit input: Clock signal for port A. Also clocks port B when
                                       // parameter CLOCKING_MODE is "common_clock".

      .clkb(s_aclk),                     // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                       // "independent_clock". Unused when parameter CLOCKING_MODE is
                                       // "common_clock".

      .dina(ram_data_in),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      .dinb(0),                     // WRITE_DATA_WIDTH_B-bit input: Data input for port B write operations.
      .ena(1),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                       // cycles when read or write operations are initiated. Pipelined
                                       // internally.

      .enb(1),                       // 1-bit input: Memory enable signal for port B. Must be high on clock
                                       // cycles when read or write operations are initiated. Pipelined
                                       // internally.

      .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectdbiterrb(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .injectsbiterrb(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                       // ECC enabled (Error injection capability is not available in
                                       // "decode_only" mode).

      .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                       // data path.

      .regceb(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                       // data path.

      .rsta(~s_aresetn),                     // 1-bit input: Reset signal for the final port A output register stage.
                                       // Synchronously resets output port douta to the value specified by
                                       // parameter READ_RESET_VALUE_A.

      .rstb(~s_aresetn),                     // 1-bit input: Reset signal for the final port B output register stage.
                                       // Synchronously resets output port doutb to the value specified by
                                       // parameter READ_RESET_VALUE_B.

      .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
      .wea(ram_wr_en),                       // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                       // for port A input data port dina. 1 bit wide when word-wide writes are
                                       // used. In byte-wide write configurations, each bit controls the
                                       // writing one byte of dina to address addra. For example, to
                                       // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                       // is 32, wea would be 4'b0010.

      .web(0)                        // WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B-bit input: Write enable vector
                                       // for port B input data port dinb. 1 bit wide when word-wide writes are
                                       // used. In byte-wide write configurations, each bit controls the
                                       // writing one byte of dinb to address addrb. For example, to
                                       // synchronously write only bits [15-8] of dinb when WRITE_DATA_WIDTH_B
                                       // is 32, web would be 4'b0010.

   );

   // End of xpm_memory_tdpram_inst instantiation
				
// end
// endgenerate


ila_xdma_control ila_xdma_control (
	.clk(s_aclk), // input wire clk


	.probe0(s_axil_awaddr), // input wire [31:0]  probe0  
	.probe1(s_axil_awvalid), // input wire [0:0]  probe1 
	.probe2(s_axil_awready), // input wire [0:0]  probe2 
	.probe3(s_axil_wdata), // input wire [31:0]  probe3 
	.probe4(s_axil_wvalid), // input wire [0:0]  probe4 
	.probe5(s_axil_wready), // input wire [0:0]  probe5 
	.probe6(s_axil_bvalid), // input wire [0:0]  probe6 
	.probe7(s_axil_bready), // input wire [0:0]  probe7 
	.probe8(s_axil_araddr), // input wire [31:0]  probe8 
	.probe9(s_axil_arvalid), // input wire [0:0]  probe9 
	.probe10(s_axil_arready), // input wire [0:0]  probe10 
	.probe11(s_axil_rdata), // input wire [31:0]  probe11 
	.probe12(s_axil_rvalid), // input wire [0:0]  probe12 
	.probe13(s_axil_rready), // input wire [0:0]  probe13 
	.probe14(w_cstate), // input wire [2:0]  probe14 
	.probe15(r_cstate), // input wire [2:0]  probe15 
	.probe16(addra_ori), // input wire [19:0]  probe16 
	.probe17(addrb_ori), // input wire [19:0]  probe17 
	.probe18(lat_timer_out), // input wire [7:0]  probe18 
	.probe19(fifo_rd_en) // input wire [0:0]  probe19	
//	.probe14(work_group_size), // input wire [31:0]  probe14 
//	.probe15(stride), // input wire [31:0]  probe15 
//	.probe16(num_mem_ops), // input wire [63:0]  probe16 
//	.probe17(mem_burst_size), // input wire [31:0]  probe17 
//	.probe18(hbm_channel), // input wire [7:0]  probe18 
//	.probe19(latency_test_enable), // input wire [0:0]  probe19
//	.probe20(lat_timer_sum_wr), // input wire [31:0]  probe20 
//	.probe21(lat_timer_sum_rd), // input wire [31:0]  probe21 
//	.probe22(w_cstate), // input wire [2:0]  probe22 
//	.probe23(r_cstate), // input wire [2:0]  probe23 
//	.probe24(wr_addr), // input wire [5:0]  probe24 
//	.probe25(wr_data), // input wire [31:0]  probe25 
//	.probe26(rd_addr), // input wire [5:0]  probe26 
//	.probe27(write_enable), // input wire [31:0]  probe27 
//	.probe28(read_enable), // input wire [31:0]  probe28 
//	.probe29(end_wr), // input wire [31:0]  probe29 
//	.probe30(end_rd), // input wire [31:0]  probe30 
//	.probe31(lat_timer_valid), // input wire [0:0]  probe31 
//	.probe32(lat_timer), // input wire [14:0]  probe32 
//	.probe33(addra), // input wire [19:0]  probe33 
//	.probe34(addrb), // input wire [19:0]  probe34 
//	.probe35({8'b0,doutb}) // input wire [15:0]  probe35
);



endmodule
