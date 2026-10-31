`timescale 1ns/1ps

module mux_sim ();

    wire       en;
    wire       mux_sel;
    wire [3:0] input_a;
    wire [3:0] input_b;
    wire [3:0] output_c;
    reg  [9:0] switch;

    assign {en, mux_sel, input_a, input_b} = switch;

    mux u_mux (
        .en       (en),
        .mux_sel  (mux_sel),
        .input_a  (input_a),
        .input_b  (input_b),
        .output_c (output_c)
    );

    // Waveform recording belongs to the testbench, not mux.v.
    initial begin
        $timeformat(-9, 0, " ns", 8);
        $dumpfile("mux.vcd");
        $dumpvars(0, en, mux_sel, input_a, input_b, output_c);
    end

    // Keep each input beside its expected output. Only this task drives switch.
    task apply_and_check;
        input [9:0] stimulus;
        input [3:0] expected;
        begin
            switch = stimulus;
            #1;
            if (output_c !== expected) begin
                $fatal(1, "FAIL t=%0t en=%b sel=%b a=%0d b=%0d actual=%b expected=%b",
                       $time, en, mux_sel, input_a, input_b, output_c, expected);
            end else begin
                $display("PASS t=%0t en=%b sel=%b a=%0d b=%0d output=%0d",
                         $time, en, mux_sel, input_a, input_b, output_c);
            end
            #4;
        end
    endtask

    // Preserve the ten course inputs, 5 ns spacing, and 55 ns finish time.
    initial begin
        apply_and_check(10'b0_1_0010_0001, 4'd15);
        apply_and_check(10'b0_0_0010_0001, 4'd15);
        apply_and_check(10'b1_0_0001_0000, 4'd1);
        apply_and_check(10'b1_0_0001_0001, 4'd2);
        apply_and_check(10'b1_0_1000_0100, 4'd12);
        apply_and_check(10'b1_0_0100_0001, 4'd5);
        apply_and_check(10'b1_1_0001_0000, 4'd1);
        apply_and_check(10'b1_1_0001_0001, 4'd0);
        apply_and_check(10'b1_1_1000_0100, 4'd4);
        apply_and_check(10'b1_1_0100_0001, 4'd3);
        $display("PASS: all 10 course test cases passed.");
        #5 $finish;
    end

endmodule
