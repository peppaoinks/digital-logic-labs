`timescale 1ns / 1ps
module lab4 #(
    parameter [31:0] STUDENT_ID = 32'h25310489,
    parameter [16:0] SCAN_MAX = 17'd99_999,
    parameter [20:0] DEBOUNCE_MAX = 21'd1_999_999,
    parameter [23:0] TICK_MAX = 24'd9_999_999
)(
    input wire clk,
    input wire rst,
    input wire button_s2,
    input wire button_s3,
    input wire mode_sel,
    output wire [7:0] led_en,
    output wire [7:0] led_cx,
    output wire [7:0] led_cx1
);
    (* ASYNC_REG = "TRUE" *) reg mode_meta;
    (* ASYNC_REG = "TRUE" *) reg mode_sync;
    reg running;
    wire s2_clean;
    wire s3_clean;
    wire s2_press;
    wire s3_raw_press;
    wire s3_clean_press;
    reg [3:0] raw_tens, raw_ones;
    reg [3:0] clean_tens, clean_ones;
    reg [3:0] auto_tens, auto_ones;
    reg [23:0] tick_cnt;
    wire tick_inc;
    wire tick_end;
    wire [31:0] display;
    // 模式同步
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode_meta <= 1'b0;
            mode_sync <= 1'b0;
        end else begin
            mode_meta <= mode_sel;
            mode_sync <= mode_meta;
        end
    end
    button_debounce #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) button_debounce_s2 (
        .clk(clk), .rst(rst), .button(button_s2), .button_clean(s2_clean)
    );
    button_debounce #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) button_debounce_s3 (
        .clk(clk), .rst(rst), .button(button_s3), .button_clean(s3_clean)
    );
    edge_detect edge_detect_s2 (
        .clk(clk), .rst(rst), .signal(s2_clean), .pos_edge(s2_press)
    );
    edge_detect edge_detect_raw (
        .clk(clk), .rst(rst), .signal(button_s3), .pos_edge(s3_raw_press)
    );
    edge_detect edge_detect_clean (
        .clk(clk), .rst(rst), .signal(s3_clean), .pos_edge(s3_clean_press)
    );
    // 按键启停
    always @(posedge clk or posedge rst) begin
        if (rst) running <= 1'b1;
        else if (s2_press) running <= ~running;
        else running <= running;
    end
    // 未消抖计数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            raw_tens <= 4'd0;
            raw_ones <= 4'd0;
        end else if (s3_raw_press && (raw_tens == 4'd9) && (raw_ones == 4'd9)) begin
            raw_tens <= 4'd0;
            raw_ones <= 4'd0;
        end else if (s3_raw_press) begin
            if (raw_ones == 4'd9) begin
                raw_tens <= raw_tens + 4'd1;
                raw_ones <= 4'd0;
            end else begin
                raw_tens <= raw_tens;
                raw_ones <= raw_ones + 4'd1;
            end
        end else begin
            raw_tens <= raw_tens;
            raw_ones <= raw_ones;
        end
    end
    // 消抖计数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clean_tens <= 4'd0;
            clean_ones <= 4'd0;
        end else if (s3_clean_press && (clean_tens == 4'd9) && (clean_ones == 4'd9)) begin
            clean_tens <= 4'd0;
            clean_ones <= 4'd0;
        end else if (s3_clean_press) begin
            if (clean_ones == 4'd9) begin
                clean_tens <= clean_tens + 4'd1;
                clean_ones <= 4'd0;
            end else begin
                clean_tens <= clean_tens;
                clean_ones <= clean_ones + 4'd1;
            end
        end else begin
            clean_tens <= clean_tens;
            clean_ones <= clean_ones;
        end
    end
    // 0.1秒计时
    assign tick_inc = running;
    assign tick_end = tick_inc & (tick_cnt == TICK_MAX);
    always @(posedge clk or posedge rst) begin
        if (rst) tick_cnt <= 24'd0;
        else if (tick_end) tick_cnt <= 24'd0;
        else if (tick_inc) tick_cnt <= tick_cnt + 24'd1;
        else tick_cnt <= tick_cnt;
    end
    // 00到20计数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            auto_tens <= 4'd0;
            auto_ones <= 4'd0;
        end else if (tick_end && (auto_tens == 4'd2) && (auto_ones == 4'd0)) begin
            auto_tens <= 4'd0;
            auto_ones <= 4'd0;
        end else if (tick_end) begin
            if (auto_ones == 4'd9) begin
                auto_tens <= auto_tens + 4'd1;
                auto_ones <= 4'd0;
            end else begin
                auto_tens <= auto_tens;
                auto_ones <= auto_ones + 4'd1;
            end
        end else begin
            auto_tens <= auto_tens;
            auto_ones <= auto_ones;
        end
    end
    assign display = mode_sync ? STUDENT_ID :
        {STUDENT_ID[7:0], raw_tens, raw_ones, clean_tens, clean_ones, auto_tens, auto_ones};
    led_ctrl_unit #(.SCAN_MAX(SCAN_MAX)) led_ctrl_unit_inst (
        .rst(rst), .clk(clk), .display(display), .led_en(led_en),
        .led_cx(led_cx), .led_cx1(led_cx1)
    );
endmodule
