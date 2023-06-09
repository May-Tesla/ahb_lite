`timescale 1ns/10ps
`include "ahb_define.vh"

module ahb_multiplexor #(
    parameter NUM_S = 3
)(
    input wire HCLK,
    input wire HRESETn,

    input wire HSEL0,
    input wire HSEL1,
    input wire HSEL2,
    input wire HSELd,

    input wire [31:0] HRDATA0,
    input wire HRESP0,
    input wire HREADY0,

    input wire [31:0] HRDATA1,
    input wire HRESP1,
    input wire HREADY1,

    input wire [31:0] HRDATA2,
    input wire HRESP2,
    input wire HREADY2,

    input wire [31:0] HRDATAd,
    input wire HRESPd,
    input wire HREADYd,

    output reg HRDATA,
    output reg HRESP,
    output reg HREADY
);
	
    localparam D_HSEL0 = 4'b0001;
    localparam D_HSEL1 = 4'b0010;
    localparam D_HSEL2 = 4'b0100;
    localparam D_HSELd = 4'b1000;
    wire [3:0] hsel = {HSELd,HSEL2,HSEL1,HSEL0};
    reg  [3:0] hsel_r;

    always @ (posedge HCLK or negedge HRESETn) begin
        if (~HRESETn)   hsel_r <= 'h0;
        else if(HREADY) hsel_r <= hsel; // default HREADY must be 1'b1
    end

    always @ (hsel_r or HREADY0 or HREADY1 or HREADY2 or HREADYd) begin
        case(hsel_r) // synopsys full_case parallel_case
            D_HSEL0: HREADY = HREADY0; // default
            D_HSEL1: HREADY = HREADY1;
            D_HSEL2: HREADY = HREADY2;
            D_HSELd: HREADY = HREADYd;
            default: HREADY = 1'b1;
        endcase
    end

    always @ (hsel_r or HRDATA0 or HRDATA1 or HRDATA2 or HRDATAd) begin
        case(hsel_r) // synopsys full_case parallel_case
            D_HSEL0: HRDATA = HRDATA0;
            D_HSEL1: HRDATA = HRDATA1;
            D_HSEL2: HRDATA = HRDATA2;
            D_HSELd: HRDATA = HRDATAd;
            default: HRDATA = 32'b0;
        endcase
    end

    always @ (hsel_r or HRESP0 or HRESP1 or HRESP2 or HRESPd) begin
        case(hsel_r) // synopsys full_case parallel_case
            D_HSEL0: HRESP = HRESP0;
            D_HSEL1: HRESP = HRESP1;
            D_HSEL2: HRESP = HRESP2;
            D_HSELd: HRESP = HRESPd;
            default: HRESP = 2'b01; //`HRESP_ERROR;
        endcase
    end


endmodule


		
			
