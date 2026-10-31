`timescale 1ns/1ps
module testbench ();
    reg clk;
    reg clr;
    reg en;
    reg d;
    wire q;

    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, testbench);
        clr = 1'b1;
        en  = 1'b0;
        clk = 1'b0;
        d   = 1'b0;
        #10;
        clr = 1'b0;
        en  = 1'b1;
        d   = 1'b1;
        #10 d = 1'b0;
        #10 d = 1'b1;
        #10;
        en = 1'b0;
        d  = 1'b0;
        #10 clr = 1'b1;
        #50 $finish;
    end

    always #5 clk = ~clk;

    initial begin
        #1;
        if (q !== 1'b0) $fatal(1, "Initial clear failed");
        #15;
        if (q !== 1'b1) $fatal(1, "Write 1 failed");
        #10;
        if (q !== 1'b0) $fatal(1, "Write 0 failed");
        #10;
        if (q !== 1'b1) $fatal(1, "Second write 1 failed");
        #10;
        if (q !== 1'b1) $fatal(1, "Disabled hold failed");
        #5;
        if (q !== 1'b0) $fatal(1, "Asynchronous clear failed");
        $display("PASS: dff course stimulus (6 checks).");
    end

    dff u_dff (
        .clk(clk),
        .clr(clr),
        .en(en),
        .d(d),
        .q(q)
    );
endmodule
