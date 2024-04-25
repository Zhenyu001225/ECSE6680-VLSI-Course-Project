

module read_64(
    input  logic clk, reset, we,
    output reg [63:0] q
);
reg [63:0] qreg = 64'b1100011;
reg [63:0] out ;
  always_ff@(posedge clk or posedge reset)
    if (~reset) begin
        out <= 0;
    end
    else begin
	if(we)
         out<=qreg;
	else 
	 out<=0;
    end
endmodule