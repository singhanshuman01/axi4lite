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
    // input wire [(DATA_WIDTH/8)-1:0] WSTRB,
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
    output reg                  RREADY
);
    
endmodule