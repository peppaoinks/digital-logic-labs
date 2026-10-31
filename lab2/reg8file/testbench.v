`timescale 1ns/1ps
module testbench ();
    reg clk;
    reg clr;
    reg en;
    reg [7:0] d;
    reg [2:0] wsel;
    reg [2:0] rsel;
    wire [7:0] q;
    integer check_count;
    integer addr;

    reg8file u_reg8file (
        .clk(clk),
        .clr(clr),
        .en(en),
        .d(d),
        .wsel(wsel),
        .rsel(rsel),
        .q(q)
    );

    always #5 clk = ~clk;

    task check_q;
        input [7:0] expected;
        begin
            if (q !== expected) begin
                $display("FAIL at %0t: rsel=%0d expected=%h actual=%h",
                         $time, rsel, expected, q);
                $fatal(1, "Register file mismatch");
            end
            check_count = check_count + 1;
        end
    endtask

    initial begin
        $dumpfile("reg8file.vcd");
        $dumpvars(0, testbench);
        clk = 1'b0;
        clr = 1'b1;
        en = 1'b0;
        d = 8'h00;
        wsel = 3'd0;
        rsel = 3'd0;
        check_count = 0;
        #1; check_q(8'h00);

        // 向二号寄存器写入数据
        #9;
        clr = 1'b0;
        en = 1'b1;
        wsel = 3'd2;
        rsel = 3'd2;
        d = 8'ha5;
        #1; check_q(8'h00);
        #5; check_q(8'ha5);

        // 向五号寄存器写入另一组数据
        #4;
        wsel = 3'd5;
        d = 8'h3c;
        #6; check_q(8'ha5);
        #4;
        en = 1'b0;
        d = 8'hff;
        // 关闭写使能，分别读取两个寄存器
        #2; rsel = 3'd5;
        #1; check_q(8'h3c);
        #1; rsel = 3'd2;
        #1; check_q(8'ha5);
        #1; check_q(8'ha5);
        #1; rsel = 3'd5;
        #1; check_q(8'h3c);
        // 在两个上升沿之间清零
        #4; clr = 1'b1;
        #1; check_q(8'h00);
        #1; rsel = 3'd2;
        #1; check_q(8'h00);
        #1; clr = 1'b0;

        for (addr = 0; addr < 8; addr = addr + 1) begin
            @(negedge clk);
            en = 1'b1;
            wsel = addr[2:0];
            d = 8'h81 + addr[7:0];
            @(posedge clk);
            #1;
        end
        @(negedge clk);
        en = 1'b0;
        for (addr = 0; addr < 8; addr = addr + 1) begin
            rsel = addr[2:0];
            #1; check_q(8'h81 + addr[7:0]);
        end
        for (addr = 0; addr < 8; addr = addr + 1) begin
            @(negedge clk);
            wsel = addr[2:0];
            rsel = addr[2:0];
            d = 8'hff;
            @(posedge clk);
            #1; check_q(8'h81 + addr[7:0]);
        end
        @(negedge clk);
        en = 1'b1;
        #2; clr = 1'b1;
        #1; check_q(8'h00);
        @(posedge clk);
        #1; check_q(8'h00);
        @(negedge clk);
        en = 1'b0;
        clr = 1'b0;
        for (addr = 0; addr < 8; addr = addr + 1) begin
            rsel = addr[2:0];
            #1; check_q(8'h00);
        end
        $display("PASS: reg8file (%0d checks).", check_count);
        #2; $finish;
    end
endmodule
