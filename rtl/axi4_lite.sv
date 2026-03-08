module axi4_lite #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    axi4_lite_if.slave axi
);

    // ------------------------------------------------
    // Register file (16 x 32-bit)
    // ------------------------------------------------
    logic [DATA_WIDTH-1:0] regfile [0:15];

    // ------------------------------------------------
    // Write channel registers
    // ------------------------------------------------
    logic [ADDR_WIDTH-1:0] awaddr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [(DATA_WIDTH/8)-1:0] wstrb_reg;

    logic aw_seen, w_seen; //flags for write addr and write data are accepted.

    // ------------------------------------------------
    // Read address register
    // ------------------------------------------------
    logic [ADDR_WIDTH-1:0] araddr_reg;

    wire [3:0] reg_index_w = awaddr_reg[5:2];
    wire [3:0] reg_index_r = araddr_reg[5:2];

    wire addr_valid_w = (awaddr_reg[ADDR_WIDTH-1:6] == '0);
    wire addr_valid_r = (araddr_reg[ADDR_WIDTH-1:6] == '0);

    integer i;

    // =================================================
    // WRITE ADDRESS CHANNEL
    // =================================================
    always_ff @(posedge axi.ACLK) begin
        if (!axi.ARESETn) begin
            axi.AWREADY <= 1'b0;
            aw_seen     <= 1'b0;
        end else begin
            axi.AWREADY <= !aw_seen;//slave is ready only when no address is already stored. 

            if (axi.AWREADY && axi.AWVALID) begin
                awaddr_reg <= axi.AWADDR;
                aw_seen    <= 1'b1;
            end

            if (axi.BVALID && axi.BREADY)
                aw_seen <= 1'b0;
        end
    end

    // =================================================
    // WRITE DATA CHANNEL
    // =================================================
    always_ff @(posedge axi.ACLK) begin
        if (!axi.ARESETn) begin
            axi.WREADY <= 1'b0;
            w_seen     <= 1'b0;
        end else begin
            axi.WREADY <= !w_seen;//Accept data only once no data is already stored. 

            if (axi.WREADY && axi.WVALID) begin
                wdata_reg <= axi.WDATA;
                wstrb_reg <= axi.WSTRB;
                w_seen    <= 1'b1;
            end

            if (axi.BVALID && axi.BREADY)
                w_seen <= 1'b0;
        end
    end

    // =================================================
    // REGISTER WRITE
    // =================================================
    always_ff @(posedge axi.ACLK) begin
        if (!axi.ARESETn) begin
            for (i = 0; i < 16; i++)
                regfile[i] <= '0;//on reset clear all registers 
        end else if (aw_seen && w_seen && !axi.BVALID) begin//write happens only once when addr received, data received 
		// and response not issued yet. 
            if (addr_valid_w) begin//only write if address is legal 
                for (i = 0; i < DATA_WIDTH/8; i++)
                    if (wstrb_reg[i])
                        regfile[reg_index_w][8*i +: 8]
                            <= wdata_reg[8*i +: 8];
            end
        end
    end

    // =================================================
    // WRITE RESPONSE CHANNEL
    // =================================================
    always_ff @(posedge axi.ACLK) begin
        if (!axi.ARESETn) begin
            axi.BVALID <= 1'b0;
            axi.BRESP  <= 2'b00;
        end else begin
            if (aw_seen && w_seen && !axi.BVALID) begin
                axi.BVALID <= 1'b1;
                axi.BRESP  <= addr_valid_w ? 2'b00 : 2'b10;
            end else if (axi.BVALID && axi.BREADY) begin
                axi.BVALID <= 1'b0;
            end
        end
    end

    // =================================================
// READ ADDRESS CHANNEL
// =================================================
always_ff @(posedge axi.ACLK) begin
    if (!axi.ARESETn) begin
        axi.ARREADY <= 1'b1;
        araddr_reg  <= '0;
    end else begin
        if (axi.ARREADY && axi.ARVALID) begin//AXI read address handshake
		//master is giving an address and slave is ready to accept it. 
            araddr_reg <= axi.ARADDR;
            axi.ARREADY <= 1'b0;   // stall until read completes
        end else if (axi.RVALID && axi.RREADY) begin//Read completion Handhsake
		//Data is presented and Master accepted 
            axi.ARREADY <= 1'b1;//Re-enable ARREADY after read completes
        end
    end
end

// =================================================
// READ DATA CHANNEL (FIXED)
// =================================================
always_ff @(posedge axi.ACLK) begin
    if (!axi.ARESETn) begin
        axi.RVALID <= 1'b0;
        axi.RRESP  <= 2'b00;
        axi.RDATA  <= '0;
    end else begin
        // Generate read response AFTER address is latched
        if (!axi.RVALID && !axi.ARREADY) begin//No Read data is being sent, 
		//Address is already accepted, Slave is busy with a read. 
            axi.RVALID <= 1'b1;
            axi.RRESP  <= addr_valid_r ? 2'b00 : 2'b10;
            axi.RDATA  <= addr_valid_r ? regfile[reg_index_r] : '0;
        end
        else if (axi.RVALID && axi.RREADY) begin
            axi.RVALID <= 1'b0;
        end
    end
end

endmodule
