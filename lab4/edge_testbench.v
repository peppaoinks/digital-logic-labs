`timescale 1ns / 1ps
module edge_testbench;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg signal = 1'b0;
    wire pos_edge;
    reg prev_sample = 1'b0;
    integer pulse_count = 0;
    edge_detect edge_detect_inst (
        .clk(clk), .rst(rst), .signal(signal), .pos_edge(pos_edge)
    );
    always #5 clk = ~clk;
    always @(posedge clk) begin
        #1;
        if (rst) prev_sample = 1'b0;
        else begin
            if (pos_edge !== (signal & ~prev_sample)) $fatal(1, "edge pulse mismatch");
            if (edge_detect_inst.sig_r0 !== signal || edge_detect_inst.sig_r1 !== prev_sample)
                $fatal(1, "register cascade mismatch");
            if (pos_edge) pulse_count = pulse_count + 1;
            prev_sample = signal;
        end
    end
    initial begin
        $dumpfile("edge_detect.vcd");
        $dumpvars(0, edge_testbench);
        #2 rst = 1'b1;
        #20 rst = 1'b0;
        #10 signal = 1'b1;
        #50 signal = 1'b0;
        #30 signal = 1'b1;
        #40 signal = 1'b0;
        #30;
        if (pulse_count != 2) $fatal(1, "expected two rising edges");
        $display("PASS: two-register edge detector and one-cycle pulses");
        $finish;
    end
endmodule
