`timescale 1ns / 1ps

module mat_tb;

    // Parameters
    parameter N = 3;                    // Matrix size (N x N)
    parameter DATA_WIDTH = 16;          // Data width for matrix elements

    // Inputs
    logic clk;                          // Clock signal
    logic reset;                        // Reset signal
    logic start;                        // Start signal
    logic [DATA_WIDTH-1:0] matrix_a [0:N-1][0:N-1];  // Input matrix A
    logic [DATA_WIDTH-1:0] matrix_b [0:N-1][0:N-1];  // Input matrix B

    // Outputs
    logic [DATA_WIDTH-1:0] matrix_c [0:N-1][0:N-1];  // Output matrix C
    logic done;                         // Done signal

    // Expected result for verification
    logic [DATA_WIDTH-1:0] expected_c [0:N-1][0:N-1];

    // Instantiate the Unit Under Test (UUT)
    systolic_array_matrix_mul #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .matrix_c(matrix_c),
        .done(done)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;          // 10 ns clock period
    end

    // Stimulus and Verification
    initial begin
        // Initialize matrices with test values
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                matrix_a[i][j] = i * N + j + 1;          // Example: 1,2,3,... for A
                matrix_b[i][j] = (i * N + j + 1) * 10;  // Example: 10,20,30,... for B
            end
        end

        // Compute expected result (matrix C = A * B)
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                expected_c[i][j] = 0;
                for (int k = 0; k < N; k++) begin
                    expected_c[i][j] += matrix_a[i][k] * matrix_b[k][j];
                end
            end
        end

        // Reset sequence
        reset = 1;
        start = 0;
        #20;                            // Hold reset for 20 ns
        reset = 0;
        #10;                            // Wait 10 ns after deasserting reset

        // Start computation
        start = 1;
        #10;                            // Assert start for one clock cycle (10 ns)
        start = 0;

        // Wait for computation to complete
        wait(done);                     // Wait for done signal to be asserted

        // Display and verify results
        $display("Matrix C (computed):");
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                $write("%d ", matrix_c[i][j]);
                // Check if computed value matches expected value
                if (matrix_c[i][j] !== expected_c[i][j]) begin
                    $display("Error: matrix_c[%0d][%0d] = %d, expected %d",
                             i, j, matrix_c[i][j], expected_c[i][j]);
                end
            end
            $write("\n");
        end

        $display("Test completed.");
        $finish;                        // End simulation
    end

endmodule
