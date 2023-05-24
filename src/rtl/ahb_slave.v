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
    output wire [31:0] HRDATA
);
    
    // parameter IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11;
    // parameter SINGLE = 3'b000, INCR = 3'b001, WRAP4 = 3'b010, INCR4 = 3'b011, WRAP8 = 3'b100, 
    //             INCR8 = 3'b101, WRAP16 = 3'b110, INCR16 = 3'b111;
    // parameter OKAY = 2'b00, ERROR = 2'b01, RETRY = 2'b10, SPLIT = 2'b11;

    //slave list

    assign HRESP = 2'b00; // `HRESP_OKAY;
    //---------------------------------------------------
    // CSR access signals
    localparam T_ADDR_WID = 4;
    reg  [T_ADDR_WID-1:0] T_ADDR;
    reg                   T_WREN;
    // reg                   T_RDEN;
    reg  [31:0]           T_WDATA; // should be valid during T_WREN
    wire [31:0]           T_RDATA; // should be valid after one cycle from T_RDEN
    reg  [ 2:0]           T_SIZE;
    //-------------------------------------------------
    reg [2:0] state;
    localparam  STH_IDLE   = 3'h0,
                STH_WR = 3'h1,
                STH_RD  = 3'h2;
    //-------------------------------------------------
    always @ (posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            // HRDATA    <=  ~'h0;
            HREADYout <=  1'b1;
            T_ADDR    <=   'h0;
            T_WREN    <=  1'b0;
            // T_RDEN    <=  1'b0;
            T_WDATA   <=  32'h0;
            T_SIZE    <=  3'h0;
            state     <= STH_IDLE;
        end else begin
            case (state)
            STH_IDLE: begin
                    // T_RDEN    <= 1'b0;
                    T_WREN    <= 1'b0;
                    if (HSEL && HREADYin) begin
                    case (HTRANS)
                    2'b00, 2'b01: begin //`HTRANS_IDLE, `HTRANS_BUSY
                            HREADYout <= 1'b1;
                            // T_RDEN    <= 1'b0;
                            T_WREN    <= 1'b0;
                            state     <= STH_IDLE;
                        end // HTRANS_IDLE or HTRANS_BUSY
                    2'b10, 2'b11: begin //`HTRANS_NONSEQ, `HTRANS_SEQ
                            HREADYout <= 1'b1;
                            T_ADDR    <= HADDR[T_ADDR_WID-1:0];
                            T_SIZE    <= HSIZE;
                            if (HWRITE) begin // write
                                state  <= STH_WR;
                            end else begin // read
                                // T_RDEN <= 1'b1; //byte_enable(HADDR[1:0], HSIZE);
                                state  <= STH_RD;
                            end
                        end // HTRANS_NONSEQ or HTRANS_SEQ
                    endcase // HTRANS
                    end else begin// if (HSEL && HREADYin)
                        T_WREN    <= 1'b0;
                        // T_RDEN    <= 1'b0;
                        HREADYout <= 1'b1;
                    end
            end // STH_IDLE
            STH_WR: begin
                        T_WREN    <= 1'b1;
                        T_WDATA   <= HWDATA;
                        HREADYout <= 1'b1;
                        state     <= STH_IDLE;
            end // STH_WR
            STH_RD: begin
                        HREADYout <= 1'b1;
                        // HRDATA    <= T_RDATA;
                        state     <= STH_IDLE;
            end // STH_RD
            default: state <= STH_IDLE;
            endcase // state
        end // if (HRESETn==0)
    end // always

    assign HRDATA = T_RDATA;

    // ---- ---- memory start ---- ----
    parameter ADDR_WIDTH = T_ADDR_WID;
    parameter MEM_DEPTH = 2**ADDR_WIDTH;

    reg  [31:0] sram_mem[0:MEM_DEPTH-1];
    wire wren;
    wire [ADDR_WIDTH-1:0] waddr;
    wire [31:0] wdata;
    wire [ADDR_WIDTH-1:0] raddr;
    wire [31:0] rdata;

    assign wren = T_WREN;
    assign raddr = T_ADDR;
    assign T_RDATA = rdata;
    assign waddr = T_ADDR;
    assign wdata = T_WDATA;

    // synthesis translate_off
    integer i;
    initial begin
        for(i=0; i<MEM_DEPTH; i=i+1)
            sram_mem[i] <= i*2;
    end
    // synthesis translate_on

    always @(posedge HCLK ) begin
        if(wren) sram_mem[waddr] <= wdata;
    end

    assign rdata = sram_mem[raddr];
    // ---- ---- memory end ---- ----
endmodule