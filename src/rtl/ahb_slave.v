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
	input wire HREADYin,
	// input wire [3:0] HMASTER,
	// input wire HWSTRB,
	// input wire HEXCL,
	// input wire HNONSEC,

    input wire [31:0] HWDATA,

	output wire HRESP,
	output reg  HREADYout,
	output reg  [31:0]    HRDATA
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

    assign HRESP = 2'b00; // `HRESP_OKAY;
    //---------------------------------------------------
    // CSR access signals
    localparam T_ADDR_WID = 8;
    reg  [T_ADDR_WID-1:0] T_ADDR;
    reg                   T_WREN;
    reg                   T_RDEN;
    reg  [31:0]           T_WDATA; // should be valid during T_WREN
    wire [31:0]           T_RDATA; // should be valid after one cycle from T_RDEN
    reg  [ 2:0]           T_SIZE;
    //-------------------------------------------------
    reg [2:0] state;
    localparam  STH_IDLE   = 3'h0,
                STH_WRITE0 = 3'h1,
                STH_WRITE1 = 3'h2,
                STH_READ0  = 3'h3, 
                STH_READ1  = 3'h4;
    //-------------------------------------------------
    always @ (posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HRDATA    <=  ~'h0;
            HREADYout <=  1'b1;
            T_ADDR    <=   'h0;
            T_WREN    <=  1'b0;
            T_RDEN    <=  1'b0;
            T_WDATA   <=  ~'h0;
            T_SIZE    <=  3'h0;
            state     <= STH_IDLE;
        end else begin
            case (state)
            STH_IDLE: begin
                    T_RDEN    <= 1'b0;
                    T_WREN    <= 1'b0;
                    if (HSEL && HREADYin) begin
                    case (HTRANS)
                    2'b00, 2'b01: begin //`HTRANS_IDLE, `HTRANS_BUSY
                            HREADYout <= 1'b1;
                            T_RDEN    <= 1'b0;
                            T_WREN    <= 1'b0;
                            state     <= STH_IDLE;
                        end // HTRANS_IDLE or HTRANS_BUSY
                    2'b10, 2'b11: begin //`HTRANS_NONSEQ, `HTRANS_SEQ
                            HREADYout <= 1'b0;
                            T_ADDR    <= HADDR[T_ADDR_WID-1:0];
                            T_SIZE    <= HSIZE;
                            if (HWRITE) begin // write
                                state  <= STH_WRITE0;
                            end else begin // read
                                T_RDEN <= 1'b1; //byte_enable(HADDR[1:0], HSIZE);
                                state  <= STH_READ0;
                            end
                        end // HTRANS_NONSEQ or HTRANS_SEQ
                    endcase // HTRANS
                    end else begin// if (HSEL && HREADYin)
                        T_WREN    <= 1'b0;
                        T_RDEN    <= 1'b0;
                        HREADYout <= 1'b1;
                    end
            end // STH_IDLE
            STH_WRITE0: begin
                        T_WREN    <= 1'b1;
                        T_WDATA   <= HWDATA;
                        HREADYout <= 1'b1;
                        state     <= STH_WRITE1;
            end // STH_WRITE0
            STH_WRITE1: begin
                        T_WREN    <= 1'b0;
                        T_WDATA   <= 32'b0;
                        HREADYout <= 1'b1;
                        state     <= STH_IDLE;
            end // STH_WRITE1
            STH_READ0: begin
                        T_RDEN    <= 1'b0;
                        state     <= STH_READ1;
            end // STH_READ0
            STH_READ1: begin
                        HREADYout <= 1'b1;
                        HRDATA    <= T_RDATA;
                        state     <= STH_IDLE;
            end // STH_READ1
            default: state <= STH_IDLE;
            endcase // state
        end // if (HRESETn==0)
    end // always

endmodule


		
			
