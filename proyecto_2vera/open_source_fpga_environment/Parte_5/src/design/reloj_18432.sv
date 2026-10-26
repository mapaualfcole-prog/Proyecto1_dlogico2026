module reloj_18432 (
    input  logic clk,
    output logic clk_out
);

    logic [31:0] fase = 32'd0;

    localparam logic [31:0] INCREMENTO = 32'd293203100;

    always_ff @(posedge clk) begin
        fase <= fase + INCREMENTO;
    end

    assign clk_out = fase[31];

endmodule