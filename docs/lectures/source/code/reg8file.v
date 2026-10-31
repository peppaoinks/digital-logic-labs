module reg8file (
    input  wire       clk,
    input  wire       clr,
    input  wire       en,
    input  wire [7:0] d,
    input  wire [2:0] wsel,
    input  wire [2:0] rsel,
    output reg  [7:0] q
);
    reg [7:0] regfile [7:0];

    always @(posedge clk or posedge clr) begin
        if (clr) begin
            regfile[0] <= 8'h00;
            regfile[1] <= 8'h00;
            regfile[2] <= 8'h00;
            regfile[3] <= 8'h00;
            regfile[4] <= 8'h00;
            regfile[5] <= 8'h00;
            regfile[6] <= 8'h00;
            regfile[7] <= 8'h00;
        end else if (en) begin
            regfile[wsel] <= d;
        end else begin
            regfile[wsel] <= regfile[wsel];
        end
    end

    always @(*) begin
        q = regfile[rsel];
    end
endmodule
