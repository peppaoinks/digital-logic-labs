`timescale 1ns / 1ps
module testbench;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg button_s2 = 1'b0;
    reg button_s3 = 1'b0;
    reg mode_sel = 1'b1;
    wire [7:0] led_en, led_cx, led_cx1;
    lab4 #(.SCAN_MAX(17'd9), .DEBOUNCE_MAX(21'd9), .TICK_MAX(24'd99)) lab4_inst (
        .clk(clk), .rst(rst), .button_s2(button_s2), .button_s3(button_s3),
        .mode_sel(mode_sel), .led_en(led_en), .led_cx(led_cx), .led_cx1(led_cx1)
    );
    always #5 clk = ~clk;
    task press_s3;
        begin
            button_s3 = 1'b1; #30;
            button_s3 = 1'b0; #30;
            button_s3 = 1'b1; #20;
            button_s3 = 1'b0; #20;
            button_s3 = 1'b1; #300;
            button_s3 = 1'b0; #30;
            button_s3 = 1'b1; #30;
            button_s3 = 1'b0; #300;
        end
    endtask
    initial begin
        $dumpfile("lab4.vcd");
        $dumpvars(0, testbench);
        #2 rst = 1'b1;
        #20 rst = 1'b0;
        #978;
        // 完整轮询
        mode_sel = 1'b0;
        #100;
        press_s3;
        press_s3;
        // 暂停与继续
        button_s2 = 1'b1; #300;
        button_s2 = 1'b0; #1500;
        button_s2 = 1'b1; #300;
        button_s2 = 1'b0; #1200;
        $finish;
    end
endmodule
