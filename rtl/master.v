module master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    // global clock and async active low reset
    input                       ACLK,
    input                       ARESETN,

    // write address channel
    output reg [ADDR_WIDTH-1:0] AWADDR,
    output reg                  AWVALID,
    input                       AWREADY,

    // write data channel
    output reg [DATA_WIDTH-1:0] WDATA,
    output reg                  WVALID,
    input                       WREADY,

    // write response channel
    input [1:0]                 BRESP,
    input                       BVALID,
    output reg                  BREADY,

    // read address channel
    output reg [ADDR_WIDTH-1:0] ARADDR,
    output reg                  ARVALID,
    input                       ARREADY,

    // read data channel
    input [DATA_WIDTH-1:0]      RDATA,
    input [1:0]                 RRESP,
    input                       RVALID,
    output reg                  RREADY,


    input                       start_write,
    input [ADDR_WIDTH-1:0]      write_addr,
    input [DATA_WIDTH-1:0]      write_data,

    input                       start_read,
    input [ADDR_WIDTH-1:0]      read_addr,
    output reg [DATA_WIDTH-1:0] read_data
);

// WRITE TRANSACTION

localparam W_IDLE = 2'b00,                          // WRITE STATES
           W_INIT = 2'b01,
           W_WAIT = 2'b10,
           W_DONE = 2'b11;

reg [1:0] state;

reg [1:0] bresp_latch;

always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
        AWVALID <= 1'b0;
        WVALID <= 1'b0;
        BREADY <= 1'b0;
    end else begin
        case (state)
            W_IDLE: begin
                AWVALID <= 1'b0;
                WVALID <= 1'b0;
                BREADY <= 1'b0;
                if(start_write) state <= W_INIT;
            end
            W_INIT: begin
                AWADDR <= write_addr;
                AWVALID <= 1'b1;

                WDATA <= write_data;
                WVALID <= 1'b1;

                state <= W_WAIT;
            end
            W_WAIT: begin
                if(AWREADY) AWVALID <= 1'b0;
                if(WREADY) WVALID <= 1'b0;

                if(BVALID) begin
                    state <= W_DONE;
                    BREADY <= 1'b1;
                end
            end
            W_DONE: begin
                bresp_latch <= BRESP;
                state <= W_IDLE;
            end
            default: ;
        endcase
    end
end


// READ TRANSACTION

reg [1:0] rresp_latch;

always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
        ARVALID <= 1'b0;
        RREADY <= 1'b0;
    end else begin
        RREADY <= 1'b0;
        if(start_read && !ARVALID && !RVALID) begin
            ARVALID <= 1'b1;
            ARADDR <= read_addr;
        end

        if(ARVALID && ARREADY) ARVALID <= 1'b0;

        if(RVALID && !RREADY) RREADY <= 1'b1;

        if(RVALID && RREADY) begin
            read_data <= RDATA;
            rresp_latch <= RRESP;
            RREADY <= 1'b0;
        end
    end
end
    
endmodule