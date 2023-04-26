`timescale 1ns/10ps
`include "ahb_define.vh"

module ahb_default_slave(
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
	output wire HREADYOUT,
	output wire [31:0]    HRDATA
);
	
    wire        hsel = HSEL;
    wire [31:0] haddr = HADDR;
    wire [31:0] hwdata = HWDATA;
    wire        hwrite = HWRITE;
    wire [ 1:0] htrans = HTRANS;
    wire [ 2:0] hsize = HSIZE;
    wire [ 2:0] hburst = HBURST;
    wire [ 3:0] hprot = HPROT;
    wire        hmasterlock = HMASTERLOCK;
    wire        hready = HREADY;

    reg         hresp;
    reg         hreadyout;
    reg  [31:0] hrdata = 32'h0;

    assign HRESP = hresp;
    assign HREADYOUT = hreadyout;
    assign HRDATA = hrdata;

    reg [1:0] state;
    localparam  STH_IDLE   = 2'h0,
                STH_WRITE  = 2'h1,
                STH_READ   = 2'h2;

    always @ (posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            hresp     <= 1'b0; //`HRESP_OKAY;
            hreadyout <= 1'b1;
        end else begin
            case (state)
            STH_IDLE: begin
                if (hsel && hready) begin
                    case (htrans)
                    `IDLE, `BUSY: begin
                        hreadyout <= 1'b1;
                        hresp     <= 1'b0; //`HRESP_OKAY;
                    end
                    `NONSEQ, `SEQ: begin
                        hreadyout <= 1'b0;
                        hresp     <= 1'b1; //`HRESP_ERROR;
                    end
                    endcase
                    end else begin
                        hreadyout <= 1'b1;
                        hresp     <= 1'b0; //`HRESP_OKAY;
                    end
                end // STH_IDLE
            STH_WRITE: begin
                hreadyout <= 1'b1;
                hresp     <= 1'b1; //`HRESP_ERROR;
            end // STH_WRITE
            STH_READ: begin
                hreadyout <= 1'b1;
                hresp     <= 1'b1; //`HRESP_ERROR;
            end // STH_READ0
            endcase // state
        end
    end

    always @ (posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            state     <= STH_IDLE;
        else begin
            case (state)
            STH_IDLE: begin
                if (hsel && hready) begin
                    case (htrans)
                    `IDLE, `BUSY:
                        state     <= STH_IDLE;
                    `NONSEQ, `SEQ: begin
                        if (hwrite)
                            state <= STH_WRITE;
                        else
                            state <= STH_READ;
                    end
                    endcase // HTRANS
                end
            end // STH_IDLE
            STH_WRITE: 
                state     <= STH_IDLE;
            STH_READ:
                state     <= STH_IDLE;
            endcase // state
        end
    end

endmodule


		
			
