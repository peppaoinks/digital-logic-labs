`timescale 1ns / 1ps
module default_timing_verify;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg freq_ctrl = 1'b0;
    wire [7:0] led;
    flowing_water_lights u_flowing_water_lights (
        .clk(clk), .rst(rst), .freq_ctrl(freq_ctrl),
        .dir_ctrl(1'b0), .mode_sel(1'b0), .led(led)
    );
    always #5 clk = ~clk;
    initial begin
        #2 rst = 1'b1;
        #1;
        if (led !== 8'h01 || u_flowing_water_lights.cnt !== 24'd0)
            $fatal(1, "异步复位错误");
        #19 rst = 1'b0;
        #99999992;
        if (led !== 8'h01 || u_flowing_water_lights.cnt !== 24'd9999999)
            $fatal(1, "慢档提前换灯或计数上限错误");
        #2;
        if (led !== 8'h02 || u_flowing_water_lights.cnt !== 24'd0)
            $fatal(1, "慢档没有在第一千万个时钟换灯");
        #4 freq_ctrl = 1'b1;
        #1999994;
        if (led !== 8'h02 || u_flowing_water_lights.cnt !== 24'd199999)
            $fatal(1, "快档提前换灯或计数上限错误");
        #2;
        if (led !== 8'h04 || u_flowing_water_lights.cnt !== 24'd0)
            $fatal(1, "快档换灯错误");
        #1999998;
        if (led !== 8'h04 || u_flowing_water_lights.cnt !== 24'd199999)
            $fatal(1, "第二个快档间隔错误");
        #2;
        if (led !== 8'h08 || u_flowing_water_lights.cnt !== 24'd0)
            $fatal(1, "第二次快档换灯错误");
        $display("默认24位参数验证通过：慢档千万次计数、快档两次二十万计数，切换无需复位。");
        $finish;
    end
endmodule
