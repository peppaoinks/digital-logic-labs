`timescale 1ns / 1ps

module counter #(
    parameter WIDTH = 24,
    parameter [WIDTH-1:0] CNT_MAX_FAST = 24'd199_999,
    parameter [WIDTH-1:0] CNT_MAX_SLOW = 24'd9_999_999
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             freq_ctrl,
    output reg  [WIDTH-1:0] cnt,
    output wire             cnt_end
);
    wire [WIDTH-1:0] cnt_max;
    wire cnt_inc;

    // 计数条件
    assign cnt_max = freq_ctrl ? CNT_MAX_FAST : CNT_MAX_SLOW;
    assign cnt_end = cnt_inc & (cnt >= cnt_max);
    assign cnt_inc = 1'b1;

    always @(posedge clk or posedge rst) begin
        if (rst)          cnt <= {WIDTH{1'b0}};
        else if (cnt_end) cnt <= {WIDTH{1'b0}};
        else if (cnt_inc) cnt <= cnt + 1'b1;
        else              cnt <= cnt;
    end
endmodule
