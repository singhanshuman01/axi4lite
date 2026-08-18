module slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input aclk,
    input arst_n,

    input [ADDR_WIDTH-1:0]  awaddr,
    input                   awvalid,
    output reg              awready,

    input [DATA_WIDTH-1:0]  wdata,
    input                   wvalid,
    output reg              wready,

    output reg [1:0]        bresp,
    output                  bvalid,
    input                   bready,


    input [ADDR_WIDTH-1:0]  araddr,
    input                   arvalid,
    output reg              arready,

    output reg [DATA_WIDTH-1:0] rdata,
    output reg                  rvalid,
    input                       rready
);


    
endmodule