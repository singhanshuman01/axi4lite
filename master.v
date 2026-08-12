module master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    // global clock and async active low reset
    input ACLK,
    input ARESETN,

    // write address channel
    input wire [ADDR_WIDTH-1:0] AWADDR,
    input wire AWVALID,
    output reg AWREADY,

    // write data channel
    input wire [DATA_WIDTH-1:0] WDATA,
    input wire [(DATA_WIDTH/8)-1:0] WSTRB,
    input wire WVALID,
    output reg WREADY,

    // write response channel
    output reg [1:0] BRESP,
    output reg BVALID,
    input wire BREADY,

    // read address channel
    input wire [ADDR_WIDTH-1:0] ARADDR,
    input wire ARVALID,
    output reg ARREADY,

    // read data channel
    output reg [DATA_WIDTH-1:0] RDATA,
    output reg [1:0] RRESP,
    output reg RVALID,
    input wire RREADY
);
    
endmodule