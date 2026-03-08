interface axi4_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic ACLK,
    input logic ARESETn
);

    // ---------------------------------------------
    // WRITE ADDRESS CHANNEL
    // ---------------------------------------------
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic                  AWVALID;
    logic                  AWREADY;

    // ---------------------------------------------
    // WRITE DATA CHANNEL
    // ---------------------------------------------
    logic [DATA_WIDTH-1:0]   WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic                    WVALID;
    logic                    WREADY;

    // ---------------------------------------------
    // WRITE RESPONSE CHANNEL
    // ---------------------------------------------
    logic [1:0] BRESP;
    logic       BVALID;
    logic       BREADY;

    // ---------------------------------------------
    // READ ADDRESS CHANNEL
    // ---------------------------------------------
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic                  ARVALID;
    logic                  ARREADY;

    // ---------------------------------------------
    // READ DATA CHANNEL
    // ---------------------------------------------
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RVALID;
    logic                  RREADY;

    // =================================================
    // DRIVER CLOCKING BLOCK
    // Drives VALID / READY signals
    // =================================================
    clocking drv_cb @(posedge ACLK);
        default input #1step output #0;

        // Write address
        output AWADDR, AWVALID; //Master so drives 
        input  AWREADY; //Slave so samples

        // Write data
        output WDATA, WSTRB, WVALID;
        input  WREADY;

        // Write response
        input  BRESP, BVALID;
        output BREADY;

        // Read address
        output ARADDR, ARVALID;
        input  ARREADY;

        // Read data
        input  RDATA, RRESP, RVALID;
        output RREADY;
    endclocking

    // =================================================
    // MONITOR CLOCKING BLOCK
    // Samples everything
    // =================================================
    clocking mon_cb @(posedge ACLK);
        default input #1step output #0;

        input AWADDR, AWVALID, AWREADY;
        input WDATA, WSTRB, WVALID, WREADY;
        input BRESP, BVALID, BREADY;

        input ARADDR, ARVALID, ARREADY;
        input RDATA, RRESP, RVALID, RREADY;
    endclocking

    // =================================================
    // MODPORTS
    // =================================================
  modport DRIVER  (clocking drv_cb, input ACLK, ARESETn);
    modport MONITOR (clocking mon_cb, input ACLK, ARESETn);
    modport slave (
        input  ACLK, ARESETn,
        input  AWADDR, AWVALID,
        output AWREADY,
        input  WDATA, WSTRB, WVALID,
        output WREADY,
        output BRESP, BVALID,
        input  BREADY,
        input  ARADDR, ARVALID,
        output ARREADY,
        output RDATA, RRESP, RVALID,
        input  RREADY
    );

endinterface