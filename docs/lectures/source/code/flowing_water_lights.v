`timescale 1ns / 1ps
module flowing_water_lights #(
    parameter WIDTH = 24,
    parameter [WIDTH-1:0] CNT_MAX_FAST = 199_999,
    parameter [WIDTH-1:0] CNT_MAX_SLOW = 9_999_999
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       freq_ctrl,
    input  wire       dir_ctrl,
    input  wire       mode_sel,
    output reg  [7:0] led
);
    // 拨码同步
    (* ASYNC_REG = "TRUE" *) reg [2:0] ctrl_meta;
    (* ASYNC_REG = "TRUE" *) reg [2:0] ctrl_sync;
    wire [WIDTH-1:0] cnt;
    reg [7:0] led_pos;
    wire cnt_end;
    wire [7:0] next_pos;
    wire [7:0] next_pair;

    // 计数器
    counter #(
        .WIDTH(WIDTH),
        .CNT_MAX_FAST(CNT_MAX_FAST),
        .CNT_MAX_SLOW(CNT_MAX_SLOW)
    ) u_counter (
        .clk(clk),
        .rst(rst),
        .freq_ctrl(ctrl_sync[0]),
        .cnt(cnt),
        .cnt_end(cnt_end)
    );

    // 循环移位
    assign next_pos = ctrl_sync[1] ? {led_pos[0], led_pos[7:1]}
                                         : {led_pos[6:0], led_pos[7]};
    assign next_pair = next_pos | {next_pos[6:0], next_pos[7]};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ctrl_meta <= 3'b000;
            ctrl_sync <= 3'b000;
        end else begin
            ctrl_meta <= {mode_sel, dir_ctrl, freq_ctrl};
            ctrl_sync <= ctrl_meta;
        end
    end

    // 换灯控制
    // 位置与输出同步更新
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_pos <= 8'h01;
            led <= 8'h01;
        end else if (cnt_end) begin
            led_pos <= next_pos;
            if (ctrl_sync[2]) begin
                led <= next_pair;
            end else begin
                led <= next_pos;
            end
        end else begin
            led_pos <= led_pos;
            led <= led;
        end
    end
endmodule
