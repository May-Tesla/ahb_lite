`timescale 1ns/10ps
`include "ahb_define.vh"

module ahb_master(
	input wire HCLK,
	input wire HRESETn,

	output wire [31:0] HADDR,
	output wire 	   HWRITE,
	output wire [ 2:0] HSIZE,
	output wire [ 2:0] HBURST,
	output wire [ 3:0] HPROT,
	output wire [ 1:0] HTRANS,
	output wire 	   HMASTLOCK,
	output wire [31:0] HWDATA,
	// output wire [3:0] HMASTER,
	// output wire HWSTRB,
	// output wire HEXCL,
	// output wire HNONSEC,

	input wire HREADY,
	input wire HRESP,
	input wire [31:0] HRDATA
);
	 
//master list
reg m_ready;
reg [1:0] m_resp;
reg [31:0] m_rdata;
reg [1:0] m_trans;
reg [31:0] m_addr;
reg m_write;
reg [2:0] m_size;
reg [2:0] m_burst;
reg [3:0] m_prot;
reg [31:0] m_wdata;



endmodule


		
			
