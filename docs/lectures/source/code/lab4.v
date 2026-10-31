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
    reg mode_meta;
    reg mode_sync;
    reg running;
    wire s2_clean;
    wire s3_clean;
    wire s2_press;
    wire s3_raw_press;
    wire s3_clean_press;
    wire [3:0] raw_tens, raw_ones;
    wire [3:0] clean_tens, clean_ones;
    wire [3:0] auto_tens, auto_ones;
    wire [23:0] tick_cnt;
    wire tick_end;
    wire [31:0] display;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode_meta <= 1'b0;
            mode_sync <= 1'b0;
        end else begin
            mode_meta <= mode_sel;
            mode_sync <= mode_meta;
        end
    end
    button_debounce #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) u_button_debounce_s2 (
        .clk(clk), .rst(rst), .button(button_s2), .button_clean(s2_clean)
    );
    button_debounce #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) u_button_debounce_s3 (
        .clk(clk), .rst(rst), .button(button_s3), .button_clean(s3_clean)
    );
    edge_detect u_edge_detect_s2 (
        .clk(clk), .rst(rst), .signal(s2_clean), .pos_edge(s2_press)
    );
    edge_detect u_edge_detect_raw (
        .clk(clk), .rst(rst), .signal(button_s3), .pos_edge(s3_raw_press)
    );
    edge_detect u_edge_detect_clean (
        .clk(clk), .rst(rst), .signal(s3_clean), .pos_edge(s3_clean_press)
    );
    always @(posedge clk or posedge rst) begin
        if (rst) running <= 1'b1;
        else if (s2_press) running <= ~running;
        else running <= running;
    end
    bcd_counter u_bcd_counter_raw (
        .clk(clk), .rst(rst), .cnt_inc(s3_raw_press), .tens(raw_tens), .ones(raw_ones)
    );
    bcd_counter u_bcd_counter_clean (
        .clk(clk), .rst(rst), .cnt_inc(s3_clean_press), .tens(clean_tens), .ones(clean_ones)
    );
    cycle_counter #(.WIDTH(24), .CNT_MAX(TICK_MAX)) u_cycle_counter_tick (
        .clk(clk), .rst(rst), .enable(running), .cnt(tick_cnt), .cnt_end(tick_end)
    );
    bcd_counter #(.MAX_TENS(4'd2), .MAX_ONES(4'd0)) u_bcd_counter_auto (
        .clk(clk), .rst(rst), .cnt_inc(tick_end), .tens(auto_tens), .ones(auto_ones)
    );
    assign display = mode_sync ? STUDENT_ID :
        {STUDENT_ID[7:0], raw_tens, raw_ones, clean_tens, clean_ones, auto_tens, auto_ones};
    led_ctrl_unit #(.SCAN_MAX(SCAN_MAX)) u_led_ctrl_unit (
        .rst(rst), .clk(clk), .display(display), .led_en(led_en),
        .led_cx(led_cx), .led_cx1(led_cx1)
    );
endmodule
