// Subsistema 4.3: despliegue.
//  - Registra las entradas (valor binario y signo).
//  - Convierte binario -> BCD con el bcd_converter provisto (ROM con tabla de verdad).
//  - Suprime ceros a la izquierda y coloca el signo en el digito izquierdo.
//  - Usa disp_hex_mux (Chu 4.5.1) para el multiplexado.
//  - Registra las salidas an / seg.
module display_ctrl #(
  parameter REF_N = 16 )(
  input  logic       clk, reset,
  input  logic       neg,
  input  logic [9:0] value,
  output logic [3:0] an,        // activo en bajo
  output logic [6:0] seg );     // activo en alto (catodo comun), orden a b c d e f g

  // ---------------- registros de entrada ----------------
  logic [9:0] value_reg;
  logic       neg_reg;

  always_ff @(posedge clk, posedge reset)
    if (reset) begin
      value_reg <= 10'd0;
      neg_reg   <= 1'b0;
    end
    else begin
      value_reg <= value;
      neg_reg   <= neg;
    end

  // ---------------- binario a BCD (codigo provisto) ----------------
  logic [11:0] bcd;

  bcd_converter #(.N(10), .M(12)) u_bcd (
    .input_bin  (value_reg),
    .output_bcd (bcd) );

  // ---------------- digitos a mostrar ----------------
  logic [3:0] hex3, hex2, hex1, hex0;

  always_comb begin
    hex0 = bcd[3:0];                                                    // unidades siempre
    if (bcd[11:8] == 4'd0 && bcd[7:4] == 4'd0) hex1 = 4'hF;            // sin cero a la izquierda
    else                                       hex1 = bcd[7:4];
    if (bcd[11:8] == 4'd0)                     hex2 = 4'hF;
    else                                       hex2 = bcd[11:8];
    if (neg_reg)                               hex3 = 4'hE;            // signo menos
    else                                       hex3 = 4'hF;            // apagado
  end

  // ---------------- multiplexado ----------------
  logic [3:0] an_mux;
  logic [7:0] sseg_mux;

  disp_hex_mux #(.N(REF_N)) u_mux (
    .clk   (clk),
    .reset (reset),
    .hex3  (hex3),
    .hex2  (hex2),
    .hex1  (hex1),
    .hex0  (hex0),
    .dp_in (4'b0000),
    .an    (an_mux),
    .sseg  (sseg_mux) );

  // ---------------- registros de salida ----------------
  always_ff @(posedge clk, posedge reset)
    if (reset) begin
      an  <= 4'b1111;
      seg <= 7'b0000000;
    end
    else begin
      an  <= an_mux;
      seg <= sseg_mux[6:0];
    end
endmodule
