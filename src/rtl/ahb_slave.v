`timescale 1ns/10ps
`include "ahb_define.vh"

module ahb_slave(
    input wire HCLK, 
    input wire HRESETn,

	input wire HSEL,
    input wire [31:0] HADDR,
	input wire HWRITE,
	input wire [2:0] HSIZE,
    input wire [2:0] HBURST,
	input wire [3:0] HPROT,
    input wire [1:0] HTRANS,
    input wire HMASTERLOCK,
	input wire HREADY,
	// input wire [3:0] HMASTER,
	// input wire HWSTRB,
	// input wire HEXCL,
	// input wire HNONSEC,

    input wire [31:0] HWDATA,

	output wire HRESP,
	output wire HREADYout,
	output wire [31:0]    HRDATA
);
	
// parameter IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11;
// parameter SINGLE = 3'b000, INCR = 3'b001, WRAP4 = 3'b010, INCR4 = 3'b011, WRAP8 = 3'b100, 
// 			INCR8 = 3'b101, WRAP16 = 3'b110, INCR16 = 3'b111;
// parameter OKAY = 2'b00, ERROR = 2'b01, RETRY = 2'b10, SPLIT = 2'b11;

//slave list
reg ssel;
reg [31:0] saddr;
reg [31:0] swdata;
reg swrite;
reg [1:0] strans;
reg [2:0] ssize;
reg [2:0] sburst;
reg [3:0] smaster;
reg [3:0] sprot;
reg smasterlock;
reg sready;
reg [1:0] sresp;
reg [31:0] srdata;


reg [3:0] grant_id;
wire lock_or;
reg lock_or_r;
wire lock_detect_n;
reg [3:0] hmaster;
reg [3:0] hmaster_r;
wire hmasterlock;
wire [1:0] htrans;
wire [31:0] haddr;
wire hwrite;
wire [2:0] hsize;
wire [2:0] hburst;
wire [3:0] hprot;
reg [3:0] burst_count;
reg grant_enable;
wire [3:0] slave_sel;
wire [3:0] hsel;
reg [3:0] data_mux;
wire [31:0] hwdata;
reg [31:0] hrdata;
reg [1:0] hresp;
reg hready;
wire [15:0] hsplit;
reg [15:0] mask;
reg [15:0] split_or;
reg [3:0] grant_id_r;



endmodule


		
			
