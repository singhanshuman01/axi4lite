module slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input aclk,
    input arst_n,

    // write address channel
    input [ADDR_WIDTH-1:0]  awaddr,
    input                   awvalid,
    output reg              awready,

    // write data channel
    input [DATA_WIDTH-1:0]  wdata,
    input                   wvalid,
    output reg              wready,

    // write response channel
    output reg [1:0]        bresp,
    output reg              bvalid,
    input                   bready,

    // read address channel
    input [ADDR_WIDTH-1:0]  araddr,
    input                   arvalid,
    output reg              arready,

    // read data channel
    output reg [DATA_WIDTH-1:0] rdata,
    output reg [1:0]            rresp,
    output reg                  rvalid,
    input                       rready
);

// 4 registers for write/read
reg [DATA_WIDTH-1:0] ctrl;
reg [DATA_WIDTH-1:0] status;
reg [DATA_WIDTH-1:0] tx_fifo;
reg [DATA_WIDTH-1:0] rx_fifo;

// latches to hold address or data until both arrive
reg [ADDR_WIDTH-1:0] waddr_latch;
reg [DATA_WIDTH-1:0] wdata_latch;
reg have_waddr, have_wdata;                         // to indicate that address or data are succesfully latched

always @(posedge aclk or negedge arst_n) begin
    if(!arst_n) begin
        awready <= 1'b0;
        wready <= 1'b0;
        bvalid <= 1'b0;
        have_waddr <= 1'b0;
        have_wdata <= 1'b0;
    end else begin
        // assert write address ready if valid by master
        // if not already asserted
        // if not pending response of previous write
        if(awvalid && !awready && !bvalid) awready <= 1'b1;
        if(awvalid && awready) begin
            awready <= 1'b0;
            waddr_latch <= awaddr;                  // latch the write address 
            have_waddr <= 1'b1;
        end

        // assert write data ready if valid by master
        // if not already asserted
        // if not pending response of previous write
        if(wvalid && !wready && !bvalid) wready <= 1'b1;
        if(wvalid && wready) begin
            wdata_latch <= wdata;
            wready <= 1'b0;
            have_wdata <= 1'b1;
        end

        // perform write once we have both data and address
        if(have_waddr && have_wdata) begin
            if(waddr_latch[1:0] != 2'b00) begin         // if wrong byte offset
                bresp <= 2'b10;                         // generate slave error
                bvalid <= 1'b1;
            end else begin
                case (waddr_latch[3:2])                 //decode upper two bits and perform write
                    2'b00: ctrl <= wdata_latch;
                    2'b01: status <= wdata_latch;
                    2'b10: tx_fifo <= wdata_latch;
                    2'b11: rx_fifo <= wdata_latch;
                    default: ;
                endcase
                bresp <= 2'b00;                         // generate 'okay' resonse
                bvalid <= 1'b1;
            end
            have_waddr <= 1'b0;                         // clear these registers
            have_wdata <= 1'b0;
        end

        if(bvalid && bready) bvalid <= 1'b0;            // deassert bvalid once master accepts the response
    end
end

// latch to hold read address
reg [ADDR_WIDTH-1:0] raddr_latch;
reg have_raddr;                                         // register to indicate read address present

always @(posedge aclk or negedge arst_n) begin
    if(!arst_n) begin
        arready <= 1'b0;
        rvalid <= 1'b0;
        have_raddr <= 1'b0;        
    end else begin
        // assert ready if address avalid
        // not already asserted
        // if not pending response
        if(arvalid && !arready && !rvalid) arready <= 1'b1;
        
        // latch address once ready and valid
        if(arvalid && arready) begin
            arready <= 1'b0;
            raddr_latch <= araddr;
            have_raddr <= 1'b1;
        end

        if(have_raddr) begin
            if(raddr_latch[1:0] != 2'b00) begin
                rresp <= 2'b10;                             // return slave error if byte offset wrong
                rvalid <= 1'b1;
            end else begin
                case (raddr_latch[3:2])                     // decode upper bits and perform read op
                    2'b00: rdata <= ctrl;
                    2'b01: rdata <= status;
                    2'b10: rdata <= tx_fifo;
                    2'b11: rdata <= rx_fifo;
                    default: ;
                endcase
                rresp <= 2'b00;
                rvalid <= 1'b1;
            end
            have_raddr <= 1'b0;                             // clear indicator
        end

        if(rvalid && rready) rvalid <= 1'b0;                // deassert rvalid once master accepts data and response
    end
end
    
endmodule