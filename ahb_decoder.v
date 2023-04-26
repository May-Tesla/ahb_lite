`timescale 1ns/1ns
`include "ahb_define.vh"

module ahb_decoder #(
    parameter NUM_S = 3
)(
    input wire HCLK,
    input wire HRESETn,

    input wire [31:0] HADDR,

    output wire HSEL0,
    output wire HSEL1,
    output wire HSEL2,
    output wire HSELd
);

    localparam  S0_START_ADDR = 16'h0000,
                S1_START_ADDR = 16'h0010,
                S2_START_ADDR = 16'h0020,
                S3_START_ADDR = 16'h0030;
    
    localparam  S_ADDR_SIZE = 16'h0010;

    localparam  S0_END_ADDR = S0_START_ADDR + S_ADDR_SIZE - 1'b1,
                S1_END_ADDR = S1_START_ADDR + S_ADDR_SIZE - 1'b1,
                S2_END_ADDR = S2_START_ADDR + S_ADDR_SIZE - 1'b1,
                S3_END_ADDR = S3_START_ADDR + S_ADDR_SIZE - 1'b1;

    wire [15:0] h_haddr;
    assign h_haddr = HADDR[31:16];

    reg [NUM_S-1+1:0] hsel;

    always @(*) begin
        if((NUM_S>0) && (h_haddr>=S0_START_ADDR) && (h_haddr<=S0_START_ADDR))
            hsel <= 4'b0001;
        else if((NUM_S>1) && (h_haddr>=S1_START_ADDR) && (h_haddr<=S1_START_ADDR))
            hsel <= 4'b0010;
        else if((NUM_S>2) && (h_haddr>=S2_START_ADDR) && (h_haddr<=S2_START_ADDR))
            hsel <= 4'b0100;
        else
            hsel <= 4'b1000;
    end

    assign {HSELd, HSEL2, HSEL1, HSEL0} = hsel[3:0];

endmodule //ahb_decoder

//  if(((NUM_S>0) && (h_haddr>=S0_START_ADDR) && (h_haddr<=S0_START_ADDR)) ||
//     ((NUM_S>0) && (h_haddr>=S0_START_ADDR) && (h_haddr<=S0_START_ADDR)) ||
//     ((NUM_S>0) && (h_haddr>=S0_START_ADDR) && (h_haddr<=S0_START_ADDR)) )