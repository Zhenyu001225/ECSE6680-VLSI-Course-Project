module test_ComputeUnit;

    // Parameters
    parameter OUT_BIT = 32;
    parameter LANE_NUM = 8;
    parameter LOW_PRE = 0;
    parameter INWID = 4;
    parameter MAC_O = 4;
    // Clock period
    parameter CLK_PERIOD = 20;

    // Signals
    logic clk;
    logic reset;
    logic [1:0] Mode;
    logic [INWID*4-1:0] wgt[MAC_O-1:0];
    logic [INWID*4-1:0] act[MAC_O-1:0];
    logic [OUT_BIT-1:0] acc;
    logic [OUT_BIT-1:0] out;

    // Instantiate DUT
    ComputeUnit #(
        .OUT_BIT(OUT_BIT),
        .LOW_PRE(LOW_PRE),
        .INWID(INWID),
        .MAC_O(MAC_O)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ctrl(Mode),
        .wgt(wgt),
        .act(act),
        .acc(acc),
        .out(out)
    );

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Reset generation
    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        #20;
        reset = 1;
    end

    // Test stimuli
    initial begin
        #50
        repeat(20) begin
        // Randomize inputs
        acc = $urandom_range(0,9172);
        foreach (act[i]) act[i] = $urandom_range(0,9172);
        foreach (wgt[i]) wgt[i] = $urandom_range(0,9172);


        // Set mode
        //Mode = $urandom_range(0,3);
        Mode = 2'b11;
        // Wait for computation
        #20;

        // Verify output
        // Add code to compare the output with expected values

        // Finish simulation
        end
        $finish;
    end

endmodule
