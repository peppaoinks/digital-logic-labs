`timescale 1ns / 1ps
module bcd_counter #(
    parameter [3:0] MAX_TENS = 4'd9,
    parameter [3:0] MAX_ONES = 4'd9
)(
    input wire clk,
    input wire rst,
    input wire cnt_inc,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    wire cnt_end;
    assign cnt_end = cnt_inc & (tens == MAX_TENS) & (ones == MAX_ONES);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tens <= 4'd0;
            ones <= 4'd0;
        end else if (cnt_end) begin
            tens <= 4'd0;
            ones <= 4'd0;
        end else if (cnt_inc) begin
            if (ones == 4'd9) begin
                tens <= tens + 4'd1;
                ones <= 4'd0;
            end else begin
                tens <= tens;
                ones <= ones + 4'd1;
            end
        end else begin
            tens <= tens;
            ones <= ones;
        end
    end
endmodule
