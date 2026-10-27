// N is the size in bits for the input binary number
// M is the size in bits for the output BCD code

module bcd_converter #(parameter N=4, M=8 )(
  input  logic [N-1:0] input_bin,
  output logic [M-1:0] output_bcd);
  
  //ROM used as Truth Table for the conversion
  rom_reg #(.w(N),.b(M),.fileName("bcdtable.txt")) 
            ucode (.a(input_bin), .d(output_bcd)) ; // truth table storage
  
endmodule
