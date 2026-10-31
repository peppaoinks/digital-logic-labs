`timescale 1ns / 1ps
module default_verify;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg button_s3 = 1'b0;
    wire [7:0] led_en, led_cx, led_cx1;
    lab4 dut (
        .clk(clk), .rst(rst), .button_s2(1'b0), .button_s3(button_s3),
        .mode_sel(1'b0), .led_en(led_en), .led_cx(led_cx), .led_cx1(led_cx1)
    );
    always #5 clk = ~clk;
    task cycles;
        input integer count;
        begin repeat(count) @(posedge clk); #1; end
    endtask
    initial begin
        #2 rst=1'b1;
        #18;
        @(negedge clk); rst=1'b0; button_s3=1'b1;
        cycles(99_999);
        if (dut.led_ctrl_unit_inst.scan_index !== 0) $fatal(1,"scan changed too soon");
        cycles(1);
        if (dut.led_ctrl_unit_inst.scan_index !== 1 || dut.led_ctrl_unit_inst.cnt !== 0)
            $fatal(1,"default scan period is not 100000 clocks");
        cycles(1_900_000);
        if (dut.s3_clean !== 0) $fatal(1,"default debounce accepted too soon");
        cycles(2);
        if (dut.s3_clean !== 1) $fatal(1,"20ms debounce plus input sync mismatch");
        cycles(2);
        if ({dut.clean_tens,dut.clean_ones} !== 8'h01 || {dut.raw_tens,dut.raw_ones} !== 8'h01)
            $fatal(1,"default press count mismatch");
        cycles(7_999_995);
        if (dut.tick_cnt !== 24'd9_999_999 || {dut.auto_tens,dut.auto_ones} !== 8'h00)
            $fatal(1,"0.1s tick early");
        cycles(1);
        if (dut.tick_cnt !== 0 || {dut.auto_tens,dut.auto_ones} !== 8'h01)
            $fatal(1,"0.1s tick period mismatch");
        if ({dut.clean_tens,dut.clean_ones} !== 8'h01) $fatal(1,"long hold counted again");
        $display("PASS: default 1ms scan, 20ms debounce, 0.1s tick, long hold counts once");
        $finish;
    end
endmodule
