`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg rst;
    reg freq_ctrl;
    reg dir_ctrl;
    reg mode_sel;
    wire [7:0] led;

    flowing_water_lights #(
        .WIDTH(4),
        .CNT_MAX_FAST(4'd6),
        .CNT_MAX_SLOW(4'd11)
    ) u_flowing_water_lights (
        .clk(clk),
        .rst(rst),
        .freq_ctrl(freq_ctrl),
        .dir_ctrl(dir_ctrl),
        .mode_sel(mode_sel),
        .led(led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("flowing_water_lights.vcd");
        $dumpvars(0, testbench);
        rst = 1'b0;
        freq_ctrl = 1'b0;
        dir_ctrl = 1'b0;
        mode_sel = 1'b0;

        // 复位
        #2 rst = 1'b1;
        #20 rst = 1'b0;

        // 频率切换
        #278 freq_ctrl = 1'b1;

        // 模式切换
        #280 mode_sel = 1'b1;

        // 方向切换
        #300 dir_ctrl = 1'b1;
        #600 mode_sel = 1'b0;
        #600 freq_ctrl = 1'b0;

        // 双灯复位
        #600 mode_sel = 1'b1;
        #31 rst = 1'b1;
        #23 rst = 1'b0;
        #600 $finish;
    end
endmodule
