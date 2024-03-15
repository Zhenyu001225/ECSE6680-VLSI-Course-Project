`timescale 1ns / 1ps


module fir_top_tb;

    reg clk;
    reg rst_n;
    reg [1:0]rom_sel;
    wire [7:0]douta;
    wire [7:0]fir_out_data;
    
    fir_top fir_top_inst(
        .clk    (clk),
        .rst_n  (rst_n),
        .rom_sel(rom_sel),
        .douta  (douta),
        .fir_out_data(fir_out_data)
    );
    
    initial clk = 0;
    always#10 clk = ~clk;
    
    initial begin
        rst_n = 0;
        rom_sel = 0;
        #200;
        rst_n = 1'b1;
        #200000;
        rom_sel = 1;
        #200000;
        rom_sel = 2;
        #200000;
        $stop;
    end
    
endmodule
