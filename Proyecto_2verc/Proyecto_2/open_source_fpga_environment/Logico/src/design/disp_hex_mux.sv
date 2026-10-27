// Controlador de display de 7 segmentos multiplexado (Chu, sec. 4.5.1).
//
// CAMBIOS RESPECTO A LA VERSION DE CLASE (marcados con "MOD"):
//  1) Segmentos ACTIVOS EN ALTO (display de catodo comun). Se usan los valores
//     que estaban comentados en seven_segs_defs.
//  2) 4'hE se usa como signo menos y 4'hF (y default) como display apagado.
//  3) N es parametro (antes localparam) para poder simular rapido y sintetizar con N=16.
//  4) Los defines se movieron a este mismo archivo (evita problemas de orden de compilacion).
//
// Orden de bits de sseg[6:0] = a b c d e f g   (sseg[7] = punto decimal)
//----------------------------------------------------------------------
`define SS_0   7'b1111110
`define SS_1   7'b0110000
`define SS_2   7'b1101101
`define SS_3   7'b1111001
`define SS_4   7'b0110011
`define SS_5   7'b1011011
`define SS_6   7'b1011111
`define SS_7   7'b1110000
`define SS_8   7'b1111111
`define SS_9   7'b1111011
`define SS_A   7'b1110111
`define SS_B   7'b0011111
`define SS_C   7'b1001110
`define SS_D   7'b0111101
`define SS_MINUS 7'b0000001   // MOD: signo menos (segmento g)
`define SS_BLANK 7'b0000000   // MOD: apagado

module  disp_hex_mux  #(
  // refresh: barrido completo = 27 MHz / 2^N.  N=16 -> ~412 Hz (cada digito ~103 Hz)
  parameter N = 16 )   // MOD: en simulacion se usa un N pequeno
  ( 
  input   logic   clk,  reset,  
  input   logic  [3:0]  hex3, hex2 , hex1, hex0 , //  hex  digits  
  input   logic  [3:0]  dp_in ,   //  4  decimal   points  
  output  logic  [3:0]  an,       //  enable 1-out-of-4  asserted   low 
  output  logic  [7:0]  sseg      //  led   segments 
                         ); 

  //  internal   signal   declaration
  logic    [N-1:0]  q_reg;  
  logic    [N-1:0]  q_next;  
  logic    [3:0]    hex_in;  
  logic    dp ;  

  //  N-bit  counter structurally coded  
  //  register  
  always_ff@ ( posedge clk, posedge reset) 
    if  (reset) 
      q_reg  <=  0 ;  
    else  
      q_reg  <=  q_next;
                         
  //  next state logic  
  assign   q_next  =  q_reg + 1; 
  
  // This logic generates selection mux and anode control
  //  2  MSBs  of   counter   to   control   4-to-1   multiplexing  
  //  and  to generate active-low enable signal  
  always_comb 
    case   (q_reg[N-1:N-2]) //Testing the 2 MSBs from the counter 
      2'b00: 
        begin  //Assuming an active_low anode
          an      =  4'b1110; 
          hex_in  =  hex0; 
          dp      =  dp_in[0]; 
        end 
      2'b01: 
        begin  
          an      =  4'b1101; 
          hex_in  =  hex1; 
          dp      =  dp_in[1]; 
        end 
      2'b10: 
        begin  
          an     =  4'b1011; 
          hex_in =  hex2; 
          dp     =  dp_in[2] ; 
        end 
      default :  
        begin  
          an     =  4'b0111; 
          hex_in =  hex3; 
          dp     =  dp_in[3] ; 
        end 
    endcase 
  
  // hex  to   seven-segment led   display
  // This logic implements the 7-seg decoder
  always_comb  
    begin  
      case(hex_in) 
        4'h0 :  sseg[6:0]  =  `SS_0; 
        4'h1 :  sseg[6:0]  =  `SS_1; 
        4'h2 :  sseg[6:0]  =  `SS_2; 
        4'h3 :  sseg[6:0]  =  `SS_3; 
        4'h4 :  sseg[6:0]  =  `SS_4; 
        4'h5 :  sseg[6:0]  =  `SS_5; 
        4'h6 :  sseg[6:0]  =  `SS_6; 
        4'h7 :  sseg[6:0]  =  `SS_7; 
        4'h8 :  sseg[6:0]  =  `SS_8; 
        4'h9 :  sseg[6:0]  =  `SS_9; 
        4'ha :  sseg[6:0]  =  `SS_A;             
        4'hb :  sseg[6:0]  =  `SS_B; 
        4'hc :  sseg[6:0]  =  `SS_C; 
        4'hd :  sseg[6:0]  =  `SS_D; 
        4'he :  sseg[6:0]  =  `SS_MINUS;   // MOD
        default : sseg[6:0] = `SS_BLANK;   // MOD (4'hf)
      endcase  
      sseg[7]  =  dp; //Notice that this handles the decimal point
    end 
endmodule
