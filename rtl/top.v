module top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst_n,

    input start_write,
    input [ADDR_WIDTH-1:0]      write_addr,
    input [DATA_WIDTH-1:0]      write_data,

    input                       start_read,
    input [ADDR_WIDTH-1:0]      read_addr,
    output [DATA_WIDTH-1:0]     read_data,

    output                      tx_empty,
    input                       tx_clk,
    input                       tx_rst_n,
    input                       tx_rd_en,
    output [DATA_WIDTH-1:0]     tx_data,

    output                      rx_full,
    input                       rx_clk,
    input                       rx_rst_n,
    input                       rx_wr_en,
    input [DATA_WIDTH-1:0]      rx_data
);

wire [ADDR_WIDTH-1:0] AWADDR, ARADDR;
wire [DATA_WIDTH-1:0] WDATA, RDATA;
wire [1:0] BRESP, RRESP;

wire AWVALID, AWREADY, WVALID, WREADY, BVALID, BREADY, ARVALID, ARREADY, RVALID, RREADY;

master #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(DATA_WIDTH)
) inst_master (
    .ACLK(clk),
    .ARESETN(rst_n),

    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),

    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),

    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),

    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RREADY(RREADY),

    .start_write(start_write),
    .write_addr(write_addr),
    .write_data(write_data),

    .start_read(start_read),
    .read_addr(read_addr),
    .read_data(read_data)
);

slave #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(DATA_WIDTH)
) inst_slave (
    .aclk(clk),
    .arst_n(rst_n),

    .awaddr(AWADDR),
    .awvalid(AWVALID),
    .awready(AWREADY),

    .wdata(WDATA),
    .wvalid(WVALID),
    .wready(WREADY),

    .bresp(BRESP),
    .bvalid(BVALID),
    .bready(BREADY),

    .araddr(ARADDR),
    .arvalid(ARVALID),
    .arready(ARREADY),

    .rdata(RDATA),
    .rresp(RRESP),
    .rvalid(RVALID),
    .rready(RREADY),

    .full(tx_full),
    .tx_fifo_clk(tx_fifo_clk),
    .tx_fifo_rst_n(tx_fifo_rst_n),
    .tx_fifo_write_en(tx_fifo_write_en),
    .tx_fifo_data(tx_fifo_data),

    .empty(rx_empty),
    .rx_fifo_clk(rx_fifo_clk),
    .rx_fifo_rst_n(rx_fifo_rst_n),
    .rx_fifo_rd_en(rx_fifo_rd_en),
    .rx_fifo_data(rx_fifo_data)
);

wire tx_full, tx_fifo_clk, tx_fifo_rst_n, tx_fifo_write_en;
wire [DATA_WIDTH-1:0] tx_fifo_data;

wire rx_empty, rx_fifo_clk, rx_fifo_rst_n, rx_fifo_rd_en;
wire [DATA_WIDTH-1:0] rx_fifo_data;


async_fifo #(
    .DATA_WIDTH(DATA_WIDTH)
) tx_fifo_inst (
    .wclk(tx_fifo_clk),
    .rclk(tx_clk),

    .wrst_n(tx_fifo_rst_n),
    .rrst_n(tx_rst_n),

    .write_en(tx_fifo_write_en),
    .read_en(tx_rd_en),

    .w_data(tx_fifo_data),
    .r_data(tx_data),

    .empty(tx_empty),
    .full(tx_full)
);

async_fifo #(
    .DATA_WIDTH(DATA_WIDTH)
) rx_fifo_inst (
    .wclk(rx_clk),
    .rclk(rx_fifo_clk),

    .wrst_n(rx_rst_n),
    .rrst_n(rx_fifo_rst_n),

    .write_en(rx_wr_en),
    .read_en(rx_fifo_rd_en),

    .w_data(rx_data),
    .r_data(rx_fifo_data),

    .empty(rx_empty),
    .full(rx_full)
);

endmodule