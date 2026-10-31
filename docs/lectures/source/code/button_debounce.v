`timescale 1ns / 1ps
module button_debounce #(
    parameter [20:0] DEBOUNCE_MAX = 21'd1_999_999
)(
    input wire clk,
    input wire rst,
    input wire button,
    output reg button_clean
);
    reg button_meta;
    reg button_sync;
    reg [20:0] cnt;
    // 输入同步
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            button_meta <= 1'b0;
            button_sync <= 1'b0;
        end else begin
            button_meta <= button;
            button_sync <= button_meta;
        end
    end
    // 稳定20ms
    always @(posedge clk or posedge rst) begin
        if (rst) cnt <= 21'd0;
        else if (button_sync == button_clean) cnt <= 21'd0;
        else if (cnt == DEBOUNCE_MAX) cnt <= 21'd0;
        else cnt <= cnt + 21'd1;
    end
    always @(posedge clk or posedge rst) begin
        if (rst) button_clean <= 1'b0;
        else if ((button_sync != button_clean) && (cnt == DEBOUNCE_MAX))
            button_clean <= button_sync;
        else button_clean <= button_clean;
    end
endmodule
