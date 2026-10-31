`timescale 1ns / 1ps
module cycle_counter #(
    parameter WIDTH = 24,
    parameter [WIDTH-1:0] CNT_MAX = 24'd9_999_999
)(
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [WIDTH-1:0] cnt,
    output wire cnt_end
);
    wire cnt_inc;
    assign cnt_inc = enable;
    assign cnt_end = cnt_inc & (cnt == CNT_MAX);
    always @(posedge clk or posedge rst) begin
        if (rst)          cnt <= {WIDTH{1'b0}};
        else if (cnt_end) cnt <= {WIDTH{1'b0}};
        else if (cnt_inc) cnt <= cnt + 1'b1;
        else              cnt <= cnt;
    end
endmodule
