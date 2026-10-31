`timescale 1ns / 1ps
module led_ctrl_unit #(
    parameter [16:0] SCAN_MAX = 17'd99_999
)(
    input wire rst,
    input wire clk,
    input wire [31:0] display,
    output reg [7:0] led_en,
    output wire [7:0] led_cx,
    output wire [7:0] led_cx1
);
    wire [16:0] cnt;
    wire cnt_end;
    reg [2:0] scan_index;
    reg [3:0] data;
    reg [7:0] segment;
    cycle_counter #(.WIDTH(17), .CNT_MAX(SCAN_MAX)) u_cycle_counter (
        .clk(clk), .rst(rst), .enable(1'b1), .cnt(cnt), .cnt_end(cnt_end)
    );
    always @(posedge clk or posedge rst) begin
        if (rst) scan_index <= 3'd0;
        else if (cnt_end) scan_index <= scan_index + 3'd1;
        else scan_index <= scan_index;
    end
    always @(*) begin
        case (scan_index)
            3'd0: begin led_en = 8'h01; data = display[3:0]; end
            3'd1: begin led_en = 8'h02; data = display[7:4]; end
            3'd2: begin led_en = 8'h04; data = display[11:8]; end
            3'd3: begin led_en = 8'h08; data = display[15:12]; end
            3'd4: begin led_en = 8'h10; data = display[19:16]; end
            3'd5: begin led_en = 8'h20; data = display[23:20]; end
            3'd6: begin led_en = 8'h40; data = display[27:24]; end
            3'd7: begin led_en = 8'h80; data = display[31:28]; end
            default: begin led_en = 8'h00; data = 4'd0; end
        endcase
    end
    // 顺序为ABCDEFG和DP
    always @(*) begin
        case (data)
            4'h0: segment = 8'hfc;
            4'h1: segment = 8'h60;
            4'h2: segment = 8'hda;
            4'h3: segment = 8'hf2;
            4'h4: segment = 8'h66;
            4'h5: segment = 8'hb6;
            4'h6: segment = 8'hbe;
            4'h7: segment = 8'he0;
            4'h8: segment = 8'hfe;
            4'h9: segment = 8'hf6;
            4'ha: segment = 8'hee;
            4'hb: segment = 8'h3e;
            4'hc: segment = 8'h9c;
            4'hd: segment = 8'h7a;
            4'he: segment = 8'h9e;
            4'hf: segment = 8'h8e;
            default: segment = 8'h00;
        endcase
    end
    // 左右独立段选
    assign led_cx = scan_index[2] ? 8'h00 : segment;
    assign led_cx1 = scan_index[2] ? segment : 8'h00;
endmodule
