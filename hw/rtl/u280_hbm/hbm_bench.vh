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
/* ---------------------------------------------------------------------------- */
/* ------------------- AXI: can be AXI3 or AXI4 ------------------------------- */
/* ---------------------------------------------------------------------------- */
interface AXI #(
    ADDR_WIDTH   = 33 ,  // 8G-->33 bits
    DATA_WIDTH   = 256,  // 512-bit for DDR4
    PARAMS_BITS  = 256,  // parameter bits from PCIe
    ID_WIDTH     = 5,    //fixme,);
    LEN_WIDTH    = 8,
    USER_WIDTH   = 5
)();
logic                 clk;
logic                 arstn;
// AR channel
logic[ADDR_WIDTH-1:0] araddr;
logic[1:0]            arburst;
logic[3:0]            arcache;
logic[ID_WIDTH-1:0]   arid;
logic[LEN_WIDTH-1:0]  arlen;
logic[0:0]            arlock;
logic[2:0]            arprot;
logic[3:0]            arqos;
logic[3:0]            arregion;
logic[2:0]            arsize;
logic                 arready;
logic                 arvalid;
logic[USER_WIDTH-1:0] aruser;

// AW channel
logic[ADDR_WIDTH-1:0] awaddr;
logic[1:0]            awburst;
logic[3:0]            awcache;
logic[ID_WIDTH-1:0]   awid;
logic[LEN_WIDTH-1:0]  awlen;
logic[0:0]            awlock;
logic[2:0]            awprot;
logic[3:0]            awqos;
logic[3:0]            awregion;
logic[2:0]            awsize;
logic                 awready;
logic                 awvalid;
logic[USER_WIDTH-1:0] awuser;
 
// R channel
logic[DATA_WIDTH-1:0] rdata;
logic[ID_WIDTH-1:0]   rid;
logic                 rlast;
logic[1:0]            rresp;
logic                 rready;
logic                 rvalid;
logic[USER_WIDTH-1:0] ruser;

// W channel
logic[DATA_WIDTH-1:0]   wdata;
logic                   wlast;
logic[DATA_WIDTH/8-1:0] wstrb;
logic                   wready;
logic                   wvalid;
logic[USER_WIDTH-1:0]   wuser;

// B channel
logic[ID_WIDTH-1:0]   bid;
logic[1:0]            bresp;
logic                 bready;
logic                 bvalid;
logic[USER_WIDTH-1:0] buser;

// Tie off unused master signals
task tie_off_m ();
    araddr    = 0;
    arburst   = 2'b01;
    arcache   = 4'b0;
    arid      = 0;
    arlen     = 8'b0;   
    arlock    = 1'b0;   
    arprot    = 3'b0;   
    arqos     = 4'b0;   
    arregion  = 4'b0;   
    arsize    = 3'b0;   
    arvalid   = 1'b0;   
    aruser    = 0;
    awaddr    = 0;  
    awburst   = 2'b01;
    awcache   = 4'b0;   
    awid      = 0;
    awlen     = 8'b0;   
    awlock    = 1'b0;   
    awprot    = 3'b0;   
    awqos     = 4'b0;   
    awregion  = 4'b0;   
    awsize    = 3'b0;   
    awvalid   = 1'b0;
    awuser    = 0;
    bready    = 1'b0;    
    rready    = 1'b0;   
    wdata     = 0;  
    wlast     = 1'b0;
    wstrb     = 0;  
    wvalid    = 1'b0;   
    wuser     = 0;
endtask

// Tie off unused slave signals
task tie_off_s ();
    arready  = 1'b0;     
    awready  = 1'b0;
    bresp    = 2'b0;
    bvalid   = 1'b0;
    bid      = 0;   
    buser    = 0;
    rdata    = 0;
    rid      = 0;
    rlast    = 1'b0;
    rresp    = 2'b0;
    rvalid   = 1'b0;
    ruser    = 0;
    wready   = 1'b0;
endtask

// Master
modport m (
    import tie_off_m,
    input clk,input arstn,
    // AW
    input awready,
    output awaddr, awburst, awcache, awlen, awlock, awprot, awqos, awregion, awsize, awvalid, awid, awuser,
    // AR
    input arready,
    output araddr, arburst, arcache, arlen, arlock, arprot, arqos, arregion, arsize, arvalid, arid, aruser,
    // R
    input rlast, rresp, rdata, rvalid, rid, ruser,
    output rready,
    // W
    input wready,
    output wdata, wlast, wstrb, wvalid, wuser,
    // B
    input bresp, bvalid, bid, buser,
    output bready
);

// Slave
modport s (
    import tie_off_s,
    input clk,input arstn,
    // AR
    input awaddr, awburst, awcache, awlen, awlock, awprot, awqos, awregion, awsize, awvalid, awid, awuser,
    output awready,
    // AW
    input araddr, arburst, arcache, arlen, arlock, arprot, arqos, arregion, arsize, arvalid, arid, aruser,
    output arready,
    // R
    input rready,
    output rlast, rresp, rdata, rvalid, rid, ruser,
    // W
    input wdata, wlast, wstrb, wvalid, wuser,
    output wready,
    // B
    input bready,
    output bresp, bvalid, bid, buser
);
endinterface