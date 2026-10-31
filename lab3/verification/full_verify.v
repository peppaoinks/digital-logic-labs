`timescale 1ns / 1ps
module full_verify;
    reg clk;
    reg rst;
    reg freq_ctrl;
    reg dir_ctrl;
    reg mode_sel;
    wire [7:0] led;

    // 参考模型
    integer ref_cnt = 0;
    integer ref_pos = 0;
    integer ref_limit;
    integer checks = 0;
    integer setting;
    reg [2:0] ref_meta = 3'b000;
    reg [2:0] ref_sync = 3'b000;
    reg [7:0] ref_led = 8'h01;

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
        $dumpfile("full_verify.vcd");
        $dumpvars(0, full_verify);
        rst = 1'b0;
        freq_ctrl = 1'b0;
        dir_ctrl = 1'b0;
        mode_sel = 1'b0;
        #2 rst = 1'b1;
        #20 rst = 1'b0;
        // 复位、频率和模式测试
        #278 freq_ctrl = 1'b1; // 切换快档
        #280 mode_sel = 1'b1;  // 切换双灯
        #300;
        $display("Report waveform ends at 880 ns.");
        // 附加测试
        dir_ctrl = 1'b1;
        #600 mode_sel = 1'b0;
        #600 freq_ctrl = 1'b0;
        #600;
        // 双灯模式下复位
        mode_sel = 1'b1;
        #31 rst = 1'b1;
        #23 rst = 1'b0;
        #600;
        // 遍历开关组合
        for (setting = 0; setting < 8; setting = setting + 1) begin
            @(negedge clk);
            {mode_sel, dir_ctrl, freq_ctrl} = setting[2:0];
            #1200;
        end
        $display("PASS: flowing_water_lights testbench completed, %0d events checked.", checks);
        $finish;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ref_cnt = 0;
            ref_pos = 0;
            ref_meta = 3'b000;
            ref_sync = 3'b000;
            ref_led = 8'h01;
        end else begin
            ref_limit = ref_sync[0] ? 6 : 11;
            if (ref_cnt >= ref_limit) begin
                ref_cnt = 0;
                ref_pos = (ref_pos + (ref_sync[1] ? 7 : 1)) % 8;
                ref_led = 8'b1 << ref_pos;
                if (ref_sync[2])
                    ref_led = ref_led | (8'b1 << ((ref_pos + 1) % 8));
            end else begin
                ref_cnt = ref_cnt + 1;
            end
            ref_sync = ref_meta;
            ref_meta = {mode_sel, dir_ctrl, freq_ctrl};
        end
        #1;
        if (u_flowing_water_lights.cnt !== ref_cnt[3:0] || led !== ref_led ||
            u_flowing_water_lights.ctrl_sync !== ref_sync) begin
            $fatal(1, "Mismatch at %0t: cnt=%0d/%0d led=%h/%h",
                   $time, u_flowing_water_lights.cnt, ref_cnt, led, ref_led);
        end
        checks = checks + 1;
    end
endmodule
