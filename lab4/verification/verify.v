`timescale 1ns / 1ps
module verify;
    reg clk = 0, rst = 0, button_s2 = 0, button_s3 = 0, mode_sel = 1;
    wire [7:0] led_en, led_cx, led_cx1;
    integer idx, num, errors = 0;
    reg [23:0] saved_tick;
    reg [7:0] saved_auto;
    reg [7:0] expected_segments;
    reg [3:0] expected_digit;
    reg edge_prev = 0;
    reg reset_seen = 0;
    integer scan_ticks=0, scan_ref=0;
    reg [31:0] scan_display = 32'h01234567;
    wire [7:0] scan_en, scan_cx, scan_cx1;
    lab4 #(.SCAN_MAX(17'd9), .DEBOUNCE_MAX(21'd9), .TICK_MAX(24'd99)) dut (
        .clk(clk), .rst(rst), .button_s2(button_s2), .button_s3(button_s3),
        .mode_sel(mode_sel), .led_en(led_en), .led_cx(led_cx), .led_cx1(led_cx1)
    );
    led_ctrl_unit #(.SCAN_MAX(17'd9)) scan_dut (
        .clk(clk), .rst(rst), .display(scan_display), .led_en(scan_en),
        .led_cx(scan_cx), .led_cx1(scan_cx1)
    );
    function [7:0] encode;
        input [3:0] digit;
        begin
            case(digit)
                0:encode=8'hfc; 1:encode=8'h60; 2:encode=8'hda; 3:encode=8'hf2;
                4:encode=8'h66; 5:encode=8'hb6; 6:encode=8'hbe; 7:encode=8'he0;
                8:encode=8'hfe; 9:encode=8'hf6; 10:encode=8'hee; 11:encode=8'h3e;
                12:encode=8'h9c; 13:encode=8'h7a; 14:encode=8'h9e; 15:encode=8'h8e;
            endcase
        end
    endfunction
    always #5 clk = ~clk;
    task check;
        input condition;
        input [511:0] label_text;
        begin
            if (condition !== 1'b1) begin
                errors = errors + 1;
                $display("FAIL at %0t: %0s", $time, label_text);
            end
        end
    endtask
    task cycles;
        input integer count;
        begin repeat(count) begin @(posedge clk); #1; end end
    endtask
    task reset_all;
        begin
            @(negedge clk); #2 rst=1;
            #1;
            check(dut.running===1'b1 && dut.tick_cnt===0 && dut.raw_ones===0 &&
                  dut.clean_ones===0 && dut.auto_ones===0, "asynchronous reset");
            cycles(3);
            @(negedge clk); rst=0;
        end
    endtask
    task clean_press;
        begin
            @(negedge clk); button_s3=1;
            cycles(20);
            @(negedge clk); button_s3=0;
            cycles(20);
        end
    endtask
    task bounce_press;
        begin
            @(negedge clk); button_s3=1; cycles(3);
            @(negedge clk); button_s3=0; cycles(3);
            @(negedge clk); button_s3=1; cycles(2);
            @(negedge clk); button_s3=0; cycles(2);
            @(negedge clk); button_s3=1; cycles(30);
            @(negedge clk); button_s3=0; cycles(3);
            @(negedge clk); button_s3=1; cycles(3);
            @(negedge clk); button_s3=0; cycles(20);
        end
    endtask
    task toggle_s2;
        begin
            @(negedge clk); button_s2=1; cycles(3);
            @(negedge clk); button_s2=0; cycles(3);
            @(negedge clk); button_s2=1; cycles(40);
            @(negedge clk); button_s2=0; cycles(20);
        end
    endtask
    // 每拍检查扫描顺序、位宽、编码及独立段选
    always @(posedge clk) begin
        #2;
        if (!rst && reset_seen) begin
            scan_ticks=scan_ticks+1;
            if(scan_ticks==10) begin scan_ticks=0; scan_ref=(scan_ref+1)%8; end
            check(dut.led_ctrl_unit_inst.scan_index===scan_ref[2:0], "exact 10-cycle scan dwell");
            check(led_en === (8'b1 << dut.led_ctrl_unit_inst.scan_index), "one-hot enable");
            expected_digit = (dut.display >> (4*dut.led_ctrl_unit_inst.scan_index)) & 4'hf;
            expected_segments = encode(expected_digit);
            if (dut.led_ctrl_unit_inst.scan_index < 4)
                check(led_cx===expected_segments && led_cx1===0, "right segment bank");
            else
                check(led_cx1===expected_segments && led_cx===0, "left segment bank");
            check(!(edge_prev && dut.s3_clean_press), "one-cycle clean edge pulse");
            edge_prev = dut.s3_clean_press;
        end else begin
            edge_prev=0; scan_ticks=0; scan_ref=0;
            if(rst) reset_seen=1;
        end
    end
    initial begin
        reset_all;
        cycles(3);
        check(dut.display===32'h25310489, "student ID");
        // 每10拍切位，连续覆盖两圈及全部十六进制编码
        for(num=0;num<160;num=num+1) begin
            @(negedge clk);
            idx=(num/10)%8;
            if(num==80) scan_display=32'h89abcdef;
            #1;
            expected_digit=(scan_display >> (4*scan_dut.scan_index)) & 4'hf;
            check((scan_cx|scan_cx1)===encode(expected_digit), "hex decode");
            cycles(1);
        end
        reset_all;
        for(num=1;num<=21;num=num+1) begin
            cycles(100);
            check({dut.auto_tens,dut.auto_ones} === ((num%21)/10*16+(num%21)%10), "00..20 rollover and tick period");
        end
        bounce_press;
        check({dut.raw_tens,dut.raw_ones}===8'h04 && {dut.clean_tens,dut.clean_ones}===8'h01, "first bounce count 04 vs 01");
        bounce_press;
        check({dut.raw_tens,dut.raw_ones}===8'h08 && {dut.clean_tens,dut.clean_ones}===8'h02, "second bounce count 08 vs 02");
        @(negedge clk); mode_sel=0; cycles(3);
        check(dut.display[31:8]===24'h890802, "specified display mapping");
        toggle_s2;
        check(dut.running===0,"S2 bounce toggles once to pause");
        saved_tick=dut.tick_cnt; saved_auto={dut.auto_tens,dut.auto_ones};
        cycles(250);
        check(dut.tick_cnt===saved_tick && {dut.auto_tens,dut.auto_ones}===saved_auto,"pause freezes fractional interval");
        toggle_s2;
        check(dut.running===1,"S2 resumes once");
        cycles(100);
        check({dut.auto_tens,dut.auto_ones}!==saved_auto,"resume counts");
        reset_all;
        for(num=0;num<100;num=num+1) clean_press;
        check({dut.raw_tens,dut.raw_ones}===0 && {dut.clean_tens,dut.clean_ones}===0,"99 to 00 rollover");
        @(negedge clk); button_s3=1; cycles(500);
        check({dut.raw_tens,dut.raw_ones}===1 && {dut.clean_tens,dut.clean_ones}===1,"long hold counts once");
        @(negedge clk); mode_sel=0; cycles(3);
        check(dut.display[31:8]===24'h890101,"mode change preserves counters");
        reset_all;
        if(errors==0) $display("PASS: reset, scan/decode, ID, BCD rollover, bounce, hold, pause/resume, modes");
        else $fatal(1,"%0d failures",errors);
        $finish;
    end
endmodule
