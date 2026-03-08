module tb_axi4_lite;

    // ------------------------------------------------
    // Parameters
    // ------------------------------------------------
    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // ------------------------------------------------
    // Clock & Reset
    // ------------------------------------------------
    logic ACLK;
    logic ARESETn;

    // ------------------------------------------------
    // AXI Interface Instance
    // ------------------------------------------------
    // CHANGE: Replaced individual AXI signals with interface
    axi4_lite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_if (
        .ACLK    (ACLK),
        .ARESETn (ARESETn)
    );

    // ------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------
    // CHANGE: DUT connected via interface (slave modport)
    axi4_lite dut (
        .axi (axi_if)
    );

    // ------------------------------------------------
    // Clock generation (100 MHz)
    // ------------------------------------------------
    initial ACLK = 0;
    always #5 ACLK = ~ACLK;

    // ------------------------------------------------
    // AXI WRITE TASK
    // ------------------------------------------------
    task axi_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge ACLK);
        axi_if.AWADDR  <= addr;
        axi_if.AWVALID <= 1;
        axi_if.WDATA   <= data;
        axi_if.WSTRB   <= 4'b1111;
        axi_if.WVALID  <= 1;
        axi_if.BREADY  <= 0;

        // Wait for address handshake
        wait (axi_if.AWREADY);
        @(posedge ACLK);
        axi_if.AWVALID <= 0;

        // Wait for data handshake
        wait (axi_if.WREADY);
        @(posedge ACLK);
        axi_if.WVALID <= 0;

        // Wait for write response
        wait (axi_if.BVALID);
        axi_if.BREADY <= 1;
        @(posedge ACLK);
        axi_if.BREADY <= 0;
    end
    endtask

    // ------------------------------------------------
    // AXI READ TASK
    // ------------------------------------------------
    task axi_read(input [31:0] addr, output [31:0] data);
    begin
        @(posedge ACLK);
        axi_if.ARADDR  <= addr;
        axi_if.ARVALID <= 1;
        axi_if.RREADY  <= 0;

        // Wait for address handshake
        wait (axi_if.ARREADY);
        @(posedge ACLK);
        axi_if.ARVALID <= 0;

        // Wait for read data
        wait (axi_if.RVALID);
        data = axi_if.RDATA;
        axi_if.RREADY <= 1;
        @(posedge ACLK);
        axi_if.RREADY <= 0;
    end
    endtask

    // ------------------------------------------------
    // Test sequence
    // ------------------------------------------------
    initial begin
        logic [31:0] rd_data;

        // Init
        ARESETn = 0;

        axi_if.AWADDR  = 0;
        axi_if.AWVALID = 0;
        axi_if.WDATA   = 0;
        axi_if.WSTRB   = 0;
        axi_if.WVALID  = 0;
        axi_if.BREADY  = 0;

        axi_if.ARADDR  = 0;
        axi_if.ARVALID = 0;
        axi_if.RREADY  = 0;

        // Reset
        repeat (4) @(posedge ACLK);
        ARESETn = 1;

        // ------------------------------------------------
        // WRITE register 2 (0x08)
        // ------------------------------------------------
        axi_write(32'h08, 32'hAABBCCDD);

        // ------------------------------------------------
        // READ register 2 (0x08)
        // ------------------------------------------------
        axi_read(32'h08, rd_data);

        $display("READ DATA = 0x%08X", rd_data);

        // ------------------------------------------------
        // End simulation
        // ------------------------------------------------
        #20;
        $finish;
    end

endmodule
