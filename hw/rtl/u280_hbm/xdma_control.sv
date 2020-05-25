`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////


module xdma_control#(
	parameter N_MEM_INTF			      = 32,
  parameter N_ULTRARAM_INTF       = 1,
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
    input     		                       hbm_axi_clk,
    output reg                           hbm_reset,
    output reg       [ 31:0]             work_group_size,
    output reg       [ 31:0]             stride,
    output reg       [ 63:0]             num_mem_ops,
    output reg       [ 31:0]             mem_burst_size,
    output reg       [ 33:0]             initial_addr,
    output reg       [  7:0]             hbm_channel,
    output reg [N_MEM_INTF-1:0]          write_enable,
    output reg [N_MEM_INTF-1:0]          read_enable,
    output reg                           latency_test_enable,
    output reg                           start,

    input  [N_MEM_INTF-1:0]           end_wr,
    input  [N_MEM_INTF-1:0]           end_rd,
    input         [ 31:0]             lat_timer_sum_wr,
    input         [ 31:0]             lat_timer_sum_rd,
	  input                             lat_timer_valid , //log down lat_timer when lat_timer_valid is 1. 
    input         [15:0]              lat_timer
      
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
    initial_addr                 <= {dma_control_reg[ 6],2'b00};
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





  wire [15:0]                     fifo_data_out;
  reg [7:0]                       ram_data_in;
  // reg [N_ULTRARAM_INTF-1:0][7:0]  ram_data_in_r;
  // reg [ULTRARAM_NUM_WIDTH-1:0]    ram_choice;
  wire                            fifo_empty;
  wire                            fifo_rd_en;
  reg                             fifo_rd_en_r;


	always@(posedge s_aclk)begin
		if(~s_aresetn || hbm_reset || start)begin
			addra_ori					    <= 0;
		end
		else if(fifo_rd_en_r)begin
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

  assign fifo_rd_en = ~fifo_empty;

  always @(posedge s_aclk)begin
    fifo_rd_en_r                      <= fifo_rd_en;
  end

  reg[15:0] lat_timer_i;
  reg       lat_timer_valid_i;
  always @(posedge hbm_axi_clk)begin
    lat_timer_i                       <= lat_timer;
    lat_timer_valid_i                 <= lat_timer_valid;
  end

w16_d512_fwft_fifo lat_time_pri_fifo (
  .srst(~s_aresetn),                // input wire srst
  .wr_clk(hbm_axi_clk),            // input wire wr_clk
  .rd_clk(s_aclk),            // input wire rd_clk
  .din(lat_timer_i),                  // input wire [15 : 0] din
  .wr_en(lat_timer_valid_i),              // input wire wr_en
  .rd_en(fifo_rd_en),              // input wire rd_en
  .dout(fifo_data_out),                // output wire [15 : 0] dout
  .full(),                // output wire full
  .empty(fifo_empty),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

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
      ram_wr_en                <= fifo_rd_en;
    end                  
  end

  always @(posedge s_aclk)begin
    ram_data_in                   <= fifo_data_out[7:0];
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
