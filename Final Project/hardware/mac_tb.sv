module test_mac_16;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in time units
    parameter OUT_BIT = 32;
    parameter LOW_PRE = 0;
    parameter INWID = 4;
    // Signals
    logic clk, reset;
    logic [1:0] ctrl;
    logic [INWID*4-1:0] a, b;
    //logic [15:0] a, b;
    //logic [15:0] a[3:0], b[3:0];
    //logic [7:0] out;
    logic [OUT_BIT-1:0] out;
    genvar i,j;
    // Instantiate the DUT
    mac_16 #(.OUT_BIT(OUT_BIT), .LOW_PRE(LOW_PRE), .INWID(INWID)) dut (
        .clk(clk),
        .reset(reset),
        .ctrl(ctrl),
        .a(a),
        .b(b),
        .out(out)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Reset generation
    initial begin
        clk = 0;
        reset = 1;
        # 20
        reset = 0;
        #20;
        reset = 1;
    end

    // VCD file generation
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, test_mac_16);
    end

    // Test stimulus
    initial begin
        // Wait for initial reset to complete
        #100;

        // Main test loop
        repeat (20) begin
            // Generate random inputs
            ctrl = $urandom_range(0, 3);
    
            a = $urandom_range(0, 32767);
            b = $urandom_range(0, 32767);
            //a[1] = $urandom_range(0, 32767);
            //b[1] = $urandom_range(0, 32767);
            //a[2] = $urandom_range(0, 32767);
            //b[2] = $urandom_range(0, 32767);
            //a[3] = $urandom_range(0, 32767);
            //b[3] = $urandom_range(0, 32767);
            

            // Wait a few clock cycles
            #50;

            // Print inputs
            //$display("Input: ctrl=%h, a1=%h, b1=%h, a2=%h, b2=%h, a3=%h, b3=%h, a4=%h, b4=%h", ctrl, a[0], b[0], a[1], b[1], a[2], b[2], a[3], b[3]);
            $display("Input: ctrl=%h, a1=%h, b1=%h", ctrl, a, b);
            // Wait for computation to complete
            repeat (4) @(posedge clk);

            // Print output
            $display("Output: out=%h", out);
        end

        // End simulation
        $finish;
    end

endmodule