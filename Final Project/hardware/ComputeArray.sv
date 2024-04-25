module ComputeArray #(parameter OUT_BIT = 32, parameter LOW_PRE = 0, parameter INWID = 4, parameter MAC_O=4, parameter MAC_C = 8, parameter MAC_R = 32)(
    input logic clk,
    input logic reset,
    input wire[1:0] ctrl[MAC_R*MAC_C-1:0], 
    input wire[INWID*4-1:0] wgt[MAC_O*MAC_R*MAC_C-1:0],
    input wire[INWID*4-1:0] act[MAC_O*MAC_R*MAC_C-1:0],
    input wire[OUT_BIT-1:0] acc[MAC_R*MAC_C-1:0],
    output reg[OUT_BIT-1:0] out[MAC_R*MAC_C-1:0]
    );
    genvar i;
    generate
        for(i=0; i<MAC_R*MAC_C; i=i+1) begin:mac_gen
            ComputeUnit #(.OUT_BIT(OUT_BIT),.LOW_PRE(LOW_PRE),.INWID(INWID),.MAC_O(MAC_O)) compute_unit(
                .clk(clk),
                .reset(reset),
                .ctrl(ctrl[i]),
                .wgt(wgt[(i+1)*MAC_O-1:i*MAC_O]),
                .act(act[(i+1)*MAC_O-1:i*MAC_O]),
                .acc(acc[i]),
                .out(out[i]));
        end
    endgenerate
    

endmodule
module ComputeUnit #(parameter OUT_BIT = 32, parameter LOW_PRE = 0, parameter INWID = 4, parameter MAC_O=4)(
    input logic clk,
    input logic reset,
    input logic[1:0] ctrl, 
    input wire[INWID*4-1:0] wgt[MAC_O-1:0],
    input wire[INWID*4-1:0] act[MAC_O-1:0],
    input wire[OUT_BIT-1:0] acc,
    output reg[OUT_BIT-1:0] out
);

reg [OUT_BIT-1:0] out_4 [MAC_O-1:0];
reg [OUT_BIT-1:0] out_merge;

genvar i;
generate
    for(i=0; i<MAC_O; i=i+1) begin:mac_gen
        mac_16 #(.OUT_BIT(OUT_BIT),.LOW_PRE(LOW_PRE),.INWID(INWID)) mac_16bit(
            .clk(clk),
            .reset(reset),
            .ctrl(ctrl),
            .a(act[i]),
            .b(wgt[i]),
            .out(out_4[i]));
    end
endgenerate

always_comb begin
    if(~reset) begin
        out_merge = 32'b0;
    end
    else begin
        out_merge = out_4[0] + out_4[1] + out_4[2] + out_4[3] + acc;
    end
end

assign out = out_merge;

endmodule