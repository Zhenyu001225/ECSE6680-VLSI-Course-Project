module mac_16 #(parameter OUT_BIT = 32, parameter LOW_PRE = 0, parameter INWID = 4)(
    input logic clk, reset,
    input logic [1:0] ctrl,
    input wire [INWID*4-1:0] a,
    input wire [INWID*4-1:0] b,
    output reg [OUT_BIT-1:0] out
);
    // out regs
    reg [OUT_BIT-1:0] c[15:0];
    reg [OUT_BIT-1:0] out_c;

    genvar i,j;
    integer k;

    // map a b bits to 4-bit multipliers, accum 16 mul and mul16 are differnet
    generate
    if(!LOW_PRE)
        for(i=0; i<4; i=i+1) 
            for(j=0; j<4; j=j+1) 
            begin: mac_gen
                mul_4 mul_4bit(
                    .clk(clk), 
                    .reset(reset), 
                    .a   (a[i*4+3:i*4]),
                    .b   (b[j*4+3:j*4]),
                    .c   (c[j+i*4][7:0]));
            end
    else
        for(i=0; i<16; i=i+1) 
        begin: mac_gen_low
            mul_4 mul_4bit(
                .clk(clk), 
                .reset(reset), 
                .a   (a[i*4+3:i*4]),
                .b   (b[i*4+3:i*4]),
                .c   (c[i][7:0]));
        end
    endgenerate

    // initialize intermidiate out
    initial begin
        if(!LOW_PRE) begin 
            for (k=0;k<16;k=k+1) c[k][OUT_BIT-1:8] = 0;
        end
    end
    // output selection
    always_comb begin
        if (~reset) begin
            out_c = 0;
        end
        else begin
            case(ctrl) 
                2'b00: if(!LOW_PRE) out_c = 0;  // projection input is 0, out is 0
                2'b01: if(!LOW_PRE) out_c = {16'b0,a}; // projection input is 1, out is in
                2'b10: if(!LOW_PRE) out_c = -{16'b0,a}; // projection input is -1, out is -in
                2'b11: begin 
                    if(!LOW_PRE) begin
                        out_c =  c[0]        + (c[1]<<4)   + (c[4]<<4) 
                                + (c[2]<<8)   + (c[5]<<8)   + (c[8]<<8)
                                + (c[3]<<12)  + (c[6]<<12)  + (c[9]<<12) + (c[12]<<12) 
                                + (c[7]<<16)  + (c[10]<<16) + (c[13]<<16) 
                                + (c[11]<<20) + (c[14]<<20) + (c[15]<<24) ;
                        //out_c <= out_c + acc;
                    end
                    else out_c = c[0] + c[1] + c[2] + c[3]
                                + c[4] + c[5] + c[6] + c[7]
                                + c[8] + c[9] + c[10] + c[11]
                                + c[12] + c[13] + c[14] + c[15];
                    end
                default: out_c = 0;
            endcase

        end 
    end

    assign out = out_c;
endmodule

module mul_4(
    input  logic clk, reset,
    input  wire [3:0] a,b, 
    output reg [7:0] c
);
  always_comb
    if (~reset) begin
        c = 0;
    end
    else begin
        c = (a * b);
    end
endmodule





