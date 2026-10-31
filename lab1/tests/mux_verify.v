`timescale 1ns/1ps

module mux_verify ();

    reg        en;
    reg        mux_sel;
    reg  [3:0] input_a;
    reg  [3:0] input_b;
    wire [3:0] output_c;
    reg [10:0] case_id;
    reg  [4:0] reference_value;
    reg  [3:0] expected;

    mux u_mux (
        .en       (en),
        .mux_sel  (mux_sel),
        .input_a  (input_a),
        .input_b  (input_b),
        .output_c (output_c)
    );

    // Simulation-only exhaustive sweep. The 11-bit counter cannot wrap at 1023.
    initial begin
        for (case_id = 11'd0; case_id < 11'd1024;
             case_id = case_id + 11'd1) begin
            {en, mux_sel, input_a, input_b} = case_id[9:0];

            // Check subtraction independently using two's-complement addition.
            if (en == 1'b0) begin
                reference_value = 5'd15;
            end else if (mux_sel == 1'b0) begin
                reference_value = {1'b0, input_a} + {1'b0, input_b};
            end else begin
                reference_value = {1'b0, input_a} + {1'b0, ~input_b} + 5'd1;
            end
            expected = reference_value[3:0];
            #1;

            if (output_c !== expected) begin
                $fatal(1, "FAIL case=%0d en=%b sel=%b a=%0d b=%0d actual=%b expected=%b",
                       case_id, en, mux_sel, input_a, input_b, output_c, expected);
            end else begin
                // Continue testing all binary input combinations.
            end
        end

        $display("PASS: all 1024 binary input combinations passed.");
        $display("Coverage: disabled=512, addition=256, subtraction=256.");
        $finish;
    end

endmodule
