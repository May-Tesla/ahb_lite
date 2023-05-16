`timescale 1ns/10ps
`include "ahb_define.vh"

module ahb_top(
    input  wire sys_clk,     
    input  wire sys_rstn
);

    parameter NUM_S = 3;

    wire hready;

    //output for AHB master
    wire [31:0]    m_haddr;
    wire           m_hwrite;
    wire [2:0]     m_hsize;
    wire [2:0]     m_hburat;
    wire [3:0]     m_hprot;
    wire [1:0]     m_htrans;
    wire           m_hmastlock;
    wire [31:0]    m_hwdata;
    // wire [3:0] m_hmaster;
    // wire m_hwstrb;
    // wire m_hexcl;
    // wire m_hnonsec;

    wire           m_hready = hready;
    wire           m_hresp;
    wire [31:0]    m_hrdata;
    // wire           m_hexokey;

    wire [NUM_S-1:0] s_hsel;
    wire [31:0]    s_haddr;
    wire           s_hwrite;
    wire [2:0]     s_hsize;
    wire [2:0]     s_hburat;
    wire [3:0]     s_hprot;
    wire [1:0]     s_htrans;
    wire           s_hmastlock;
    wire           s_hready_in = hready;
    wire [31:0]    s_hwdata;
    // wire [3:0] s_hmaster;
    // wire s_hwstrb;
    // wire s_hexcl;
    // wire s_hnonsec;
    wire [NUM_S-1:0] s_hready_out;
    wire [NUM_S-1:0] s_hresp;
    wire [31:0] s_hrdata [NUM_S-1:0];
    // wire [NUM_S-1:0] hexokey;

    ahb_master u_ahb_master(
        .HCLK      ( sys_clk     ),
        .HRESETn   ( sys_rstn    ),
        .HADDR     ( m_haddr     ),
        .HWRITE    ( m_hwrite    ),
        .HSIZE     ( m_hsize     ),
        .HBURST    ( m_hburst    ),
        .HPROT     ( m_hprot     ),
        .HTRANS    ( m_htrans    ),
        .HMASTLOCK ( m_hmastlock ),
        .HWDATA    ( m_hwdata    ),
        // .HMASTER   ( m_hmaster   ),
        // .HWSTRB    ( m_hwstrb    ),
        // .HEXCL     ( m_hexcl     ),
        // .HNONSEC   ( m_hnonsec   ),
        .HREADY    ( m_hready    ),
        .HRESP     ( m_hresp     ),
        // .HEXOKEY     ( m_hexokey     ),
        .HRDATA    ( m_hrdata    )
    );

    ahb_slave u0_ahb_slave(
        .HCLK        ( sys_clk       ),
        .HRESETn     ( sys_rstn      ),
        .HSEL        ( s_hsel[0]     ),
        .HADDR       ( s_haddr       ),
        .HWRITE      ( s_hwrite      ),
        .HSIZE       ( s_hsize       ),
        .HBURST      ( s_hburst      ),
        .HPROT       ( s_hprot       ),
        .HTRANS      ( s_htrans      ),
        .HMASTLOCK   ( s_hmastlock   ),
        .HREADYin    ( s_hready_in   ),
        // .HMASTER     ( s_hmaster     ),
        // .HWSTRB      ( s_hwstrb      ),
        // .HEXCL       ( s_hexcl       ),
        // .HNONSEC     ( s_hnonsec     ),
        .HWDATA      ( s_hwdata      ),
        .HRESP       ( s_hresp[0]    ),
        .HREADYout   ( s_hready_out[0] ),
        // .HEXOKEY     ( s_hexokey[0]  ),
        .HRDATA      ( s_hrdata[0]   )
    );

    ahb_bus#(
        .NUM_S       ( 3 )
    )u_ahb_bus(
        .HCLK        ( sys_clk     ),
        .HRESETn     ( sys_rstn    ),

        .M_HADDR     ( m_haddr     ),   // input from master
        .M_HWRITE    ( m_hwrite    ),
        .M_HSIZE     ( m_hsize     ),
        .M_HBURST    ( m_hburst    ),
        .M_HPROT     ( m_hprot     ),
        .M_HTRANS    ( m_htrans    ),
        .M_HMASTLOCK ( m_hmastlock ),
        .M_HWDATA    ( m_hwdata    ),
        // .M_HMASTER   ( m_hmaster   ),
        // .M_HWSTRB    ( m_hwstrb    ),
        // .M_HEXCL     ( m_hexcl     ),
        // .M_HNONSEC   ( m_hnonsec   ),

        .HSEL        ( s_hsel        ),   // output to slave
        .HADDR       ( s_haddr       ),
        .HWRITE      ( s_hwrite      ),
        .HSIZE       ( s_hsize       ),
        .HBURST      ( s_hburst      ),
        .HPROT       ( s_hprot       ),
        .HTRANS      ( s_htrans      ),
        .HMASTLOCK   ( s_hmastlock   ),
        .HWDATA      ( s_hwdata      ),
        // .HMASTER     ( s_hmaster     ),
        // .HWSTRB      ( s_hwstrb      ),
        // .HEXCL       ( s_hexcl       ),
        // .HNONSEC     ( s_hnonsec     ),

        .S_HRDATA0   ( s_hrdata[0]   ),   // input from slave
        .S_HRESP0    ( s_hresp[0]    ),
        // .S_HEXOKEY0  ( s_hexokey[0]  ),
        .S_HREADY0   ( s_hready_out[0] ),

        .S_HRDATA1   ( s_hrdata[1]   ),   // input from slave
        .S_HRESP1    ( s_hresp[1]    ),
        // .S_HEXOKEY1  ( s_hexokey[1]  ),
        .S_HREADY1   ( s_hready_out[1] ),

        .S_HRDATA2   ( s_hrdata[2]   ),   // input from slave
        .S_HRESP2    ( s_hresp[2]    ),
        // .S_HEXOKEY2  ( s_hexokey[2]  ),
        .S_HREADY2   ( s_hready_out[2] ),

        .HRDATA      ( m_hrdata      ),   // output to master
        .HRESP       ( m_hresp       ),
        .HREADY      ( hready        )
    );

endmodule
