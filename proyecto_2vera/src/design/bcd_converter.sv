// Referencia obligatoria del profesor: conversion binario -> BCD via ROM.
module bcd_converter #(parameter N = 4, parameter M = 8) (
    input  logic [N-1:0] input_bin,
    output logic [M-1:0] output_bcd
);
    rom_reg #(.w(N), .b(M), .fileName("bcdtable.txt")) ucode (
        .a(input_bin), .d(output_bcd)
    );
endmodule
