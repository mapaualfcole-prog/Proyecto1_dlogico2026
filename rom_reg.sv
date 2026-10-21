// rom (arbitrary width, size)
// From Dally-Harting
//Figure 8.49
// w define el numero de bits seleccionadores de direccion (address)
// b define el numero de bits de la palabra guardada en cada posicion
module rom_reg (a, d) ;
   parameter b = 32;
   parameter w = 4;
   //TT is stored in a text file
   parameter fileName = "dataFile";
  input [w-1:0] a;
  output [b-1:0] d;
  reg [b-1:0]    rom [2**w-1:0] ; //Array declaration
   initial begin
     $readmemh(fileName, rom);
     end 
   assign d = rom[a]; //Accesing the array
endmodule // rom_reg
