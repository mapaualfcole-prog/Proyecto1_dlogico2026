module top (
    input  logic clk,
    output logic clk_out
);

    reloj_18432 u_reloj (
        .clk (clk),
        .clk_out (clk_out)
    );

endmodule