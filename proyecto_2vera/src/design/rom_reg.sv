// Referencia del profesor: ROM parametrica (Dally-Harting, fig. 8.49).
// Sin cambios funcionales. Una direccion selecciona una palabra BCD.
module rom_reg #(parameter b = 32, parameter w = 4,
                 parameter fileName = "dataFile") (
    input  wire [w-1:0] a,
    output wire [b-1:0] d
);
    reg [b-1:0] rom [0:(2**w)-1];
    initial $readmemh(fileName, rom);
    assign d = rom[a];
endmodule
