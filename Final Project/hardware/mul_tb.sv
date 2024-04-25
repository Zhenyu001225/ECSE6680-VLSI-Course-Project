
module test_mul_4;

    // Signals
    logic clk;
    logic reset;
    reg [3:0] a, b;
    wire [7:0] c;


    // Instantiate the DUT
    mul_4 dut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        clk = 0;
        reset = 1;
        #20
        reset = 0;
        #20;
        reset = 1;
    end

    // VCD file generation
    initial begin
        $dumpfile("mul_4_simulation.vcd");
        $dumpvars(0, test_mul_4);
    end

    // Test stimulus
    initial begin
        // Wait for initial reset to complete
        #100;

        // Main test loop
        repeat (10) begin
            // Generate random inputs
            a = $urandom_range(0, 7);
            b = $urandom_range(0, 7);
           

            // Wait a few clock cycles
            #5;

            // Print inputs
            $display("Input: a=%h, b=%h", a, b);

            // Print output
            $display("Output: out=%h", c);
        end

        // End simulation
        $finish;
    end

endmodule