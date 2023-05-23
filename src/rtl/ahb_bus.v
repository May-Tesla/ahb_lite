`timescale 1ns/10ps
`include "ahb_define.vh"

module ahb_bus #(
    parameter NUM_S = 3
)(
    // Global signal
    input  wire sys_clk,     
    input  wire sys_rstn,

    // Master input
	input wire [31:0] M_HADDR,
	input wire 	   M_HWRITE,
	input wire [ 2:0] M_HSIZE,
	input wire [ 2:0] M_HBURST,
	input wire [ 3:0] M_HPROT,
	input wire [ 1:0] M_HTRANS,
	input wire 	   M_HMASTLOCK,
	input wire [31:0] M_HWDATA,
	// input wire [3:0] M_HMASTER,
	// input wire M_HWSTRB,
	// input wire M_HEXCL,
	// input wire M_HNONSEC,

    // output to slave
    output wire [NUM_S-1:0] HSEL,
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

    // Slave input
    input wire [31:0] S_HRDATA0,
    input wire S_HRESP0,
    // input wire S_HEXOKEY0,
    input wire S_HREADY0,

    input wire [31:0] S_HRDATA1,
    input wire S_HRESP1,
    // input wire S_HEXOKEY1,
    input wire S_HREADY1,

    input wire [31:0] S_HRDATA2,
    input wire S_HRESP2,
    // input wire S_HEXOKEY2,
    input wire S_HREADY2,

    // Output to master
    output wire HRDATA,
    output wire HRESP,
    // output wire HEXOKEY,
    output wire HREADY
);

    //output for AHB master
    wire [31:0]    haddr;
    wire           hwrite;
    wire [2:0]     hsize;
    wire [2:0]     hburat;
    wire [3:0]     hprot;
    wire [1:0]     htrans;
    wire           hmastlock;
    wire [31:0]    hwdata;
    // wire [3:0] HMASTER;
    // wire HWSTRB;
    // wire hexcl;
    // wire hnonsec;

    // output for default AHB slave
    wire           hready_0 = S_HREADY0;
    wire           hresp_0 = S_HRESP0;
    wire [31:0]    hrdata_0 = S_HRDATA0;
    // wire           hexokey_0 = S_EXOKEY;

    // output for default AHB slave
    wire           hready_1 = S_HREADY1;
    wire           hresp_1 = S_HRESP1;
    wire [31:0]    hrdata_1 = S_HRDATA1;
    // wire           hexokey_1 = S_EXOKEY1;

    // output for default AHB slave
    wire           hready_2 = S_HREADY2;
    wire           hresp_2 = S_HRESP2;
    wire [31:0]    hrdata_2 = S_HRDATA2;
    // wire           hexokey_2 = S_EXOKEY2;

    // output for decoder
    wire hsel_0;
    wire hsel_1;
    wire hsel_2;
    wire hsel_d;

    // output for multiplexor
    wire           hready;
    wire           hresp;
    wire [31:0]    hrdata;
    // wire           hexokey;

    assign haddr = M_HADDR;
    assign hwrite = M_HWRITE;
	assign hsize = M_HSIZE;
	assign hburst = M_HBURST;
	assign hprot = M_HPROT;
	assign htrans = M_HTRANS;
	assign hmastlock = M_HMASTLOCK;
	assign hwdata = M_HWDATA;
	// assign hmaster = M_HMASTER;
	// assign hwstrb = M_HWSTRB;
	// assign hexcl = M_HEXCL;
	// assign hnonsec   = M_HNONSEC;

    assign HADDR  = M_HADDR;
    assign HTRANS = M_HTRANS;
    assign HSIZE  = M_HSIZE;
    assign HBURST = M_HBURST;
    assign HWRITE = M_HWRITE;
    assign HPROT  = M_HPROT;
    assign HWDATA = M_HWDATA;

    assign HSEL = {hsel_2, hsel_1, hsel_0};
    assign HREADY = hready;
    assign HRESP = hresp;
    // assign HEXOKEY = hexokey;
    assign HRDATA = hrdata;

    ahb_default_slave u0_ahb_default_slave (
        .HCLK        ( sys_clk     ),
        .HRESETn     ( sys_rstn    ),
        .HSEL        ( hsel_d      ),
        .HADDR       ( haddr       ),
        .HWRITE      ( hwrite      ),
        .HSIZE       ( hsize       ),
        .HBURST      ( hburst      ),
        .HPROT       ( hprot       ),
        .HTRANS      ( htrans      ),
        .HMASTLOCK   ( hmastlock   ),
        .HREADY      ( hready      ),
        // .HMASTER     ( hmaster     ),
        // .HWSTRB      ( hwstrb      ),
        // .HEXCL       ( hexcl       ),
        // .HNONSEC     ( hnonsec     ),
        .HWDATA      ( hwdata      ),
        
        .HRESP       ( hresp_d     ),
        .HREADYOUT   ( hready_d    ),
        // .HEXOKEY     ( hexokey_d   ),
        .HRDATA      ( hrdata_d    )
    );

    ahb_decoder #(
        .NUM_S   ( 3 )
    ) u_ahb_decoder (
        .HCLK    ( sys_clk  ),
        .HRESETn ( sys_rstn ),
        .HADDR   ( haddr    ),
        .HSEL0   ( hsel_0   ),
        .HSEL1   ( hsel_1   ),
        .HSEL2   ( hsel_2   ),
        .HSELd   ( hsel_d   )
    );

    ahb_multiplexor #(
        .NUM_S      ( 3 )
    ) u_ahb_multiplexor (
        .HCLK       ( sys_clk  ),
        .HRESETn    ( sys_rstn ),

        .HADDR   ( haddr    ),
        .HSEL0   ( hsel_0   ),
        .HSEL1   ( hsel_1   ),
        .HSEL2   ( hsel_2   ),
        .HSELd   ( hsel_d   ),

        .HRDATA0    ( hrdata_0   ),
        .HRESP0     ( hresp_0    ),
        .HREADY0    ( hready_0   ),
        .HRDATA1    ( hrdata_1   ),
        .HRESP1     ( hresp_1    ),
        .HREADY1    ( hready_1   ),
        .HRDATA2    ( hrdata_2   ),
        .HRESP2     ( hresp_2    ),
        .HREADY2    ( hready_2   ),
        .HRDATAd    ( hrdata_d   ),
        .HRESPd     ( hresp_d    ),
        .HREADYd    ( hready_d   ),

        .HRDATA     ( hrdata     ),
        .HRESP      ( hresp      ),
        .HREADY     ( hready     )
    );


endmodule
