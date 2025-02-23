`timescale 1ns / 1ps

module systolic_array_matrix_mul #(
    parameter N = 3,            // Matrix size (N x N)
    parameter DATA_WIDTH = 16   // Bit width of matrix elements
) (
    input  logic                  clk,
    input  logic                  reset,
    input  logic                  start,
    input  logic [DATA_WIDTH-1:0] matrix_a [N][N], // Input matrix A
    input  logic [DATA_WIDTH-1:0] matrix_b [N][N], // Input matrix B
    output logic [DATA_WIDTH-1:0] matrix_c [N][N], // Output matrix C
    output logic                  done
);

    // Internal signals for data flow
    logic [DATA_WIDTH-1:0] a_in [N];       // Inputs to left boundary
    logic [DATA_WIDTH-1:0] b_in [N];       // Inputs to top boundary
    logic [DATA_WIDTH-1:0] a_flow [N][N];  // A data flowing right
    logic [DATA_WIDTH-1:0] b_flow [N][N];  // B data flowing down
    logic [DATA_WIDTH-1:0] c_partial [N][N]; // Partial sums in PEs

    // State machine for control
    typedef enum logic [1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t state, next_state;
    logic [$clog2(2*N)-1:0] cycle_count;

    // PE array instantiation
    genvar i, j;
    generate
        for (i = 0; i < N; i++) begin : row_gen
            for (j = 0; j < N; j++) begin : col_gen
                pe #(
                    .DATA_WIDTH(DATA_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .reset(reset),
                    .a_in( j == 0 ? a_in[i] : a_flow[i][j-1] ),
                    .b_in( i == 0 ? b_in[j] : b_flow[i-1][j] ),
                    .a_out(a_flow[i][j]),
                    .b_out(b_flow[i][j]),
                    .c_out(c_partial[i][j])
                );
            end
        end
    endgenerate

    // Controller: State machine and cycle counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cycle_count <= 0;
            done <= 0;
            for (int r = 0; r < N; r++) begin
                for (int c = 0; c < N; c++) begin
                    matrix_c[r][c] <= 0;
                end
            end
        end else begin
            state <= next_state;
            if (state == COMPUTE) begin
                cycle_count <= cycle_count + 1;
                if (cycle_count == 2*N - 2) begin
                    for (int r = 0; r < N; r++) begin
                        for (int c = 0; c < N; c++) begin
                            matrix_c[r][c] <= c_partial[r][c];
                        end
                    end
                end
            end
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:    if (start) next_state = COMPUTE;
            COMPUTE: if (cycle_count == 2*N - 1) next_state = DONE;
            DONE:    if (!start) next_state = IDLE;
        endcase
    end

    // Input data feeding with skew
    always_comb begin
        for (int i = 0; i < N; i++) begin
            if (cycle_count >= i && cycle_count < i + N)
                a_in[i] = matrix_a[i][cycle_count - i];
            else
                a_in[i] = 0;
        end
        for (int j = 0; j < N; j++) begin
            if (cycle_count >= j && cycle_count < j + N)
                b_in[j] = matrix_b[cycle_count - j][j];
            else
                b_in[j] = 0;
        end
    end

endmodule

module pe #(
    parameter DATA_WIDTH = 16
) (
    input  logic                  clk,
    input  logic                  reset,
    input  logic [DATA_WIDTH-1:0] a_in,    // Input from left
    input  logic [DATA_WIDTH-1:0] b_in,    // Input from top
    output logic [DATA_WIDTH-1:0] a_out,   // Output to right
    output logic [DATA_WIDTH-1:0] b_out,   // Output to bottom
    output logic [DATA_WIDTH-1:0] c_out    // Accumulated result
);

    logic [DATA_WIDTH-1:0] c_reg;
    logic [2*DATA_WIDTH-1:0] product; // Full precision for multiplication

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            c_reg <= 0;
            a_out <= 0;
            b_out <= 0;
        end else begin
            c_reg <= c_reg + (a_in * b_in); // MAC with current inputs
            a_out <= a_in;                  // Pass A right
            b_out <= b_in;                  // Pass B down
        end
    end

    assign c_out = c_reg;

endmodule
