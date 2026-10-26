// Subsistema 4.2: resta A - B sin usar el operador "-".
// Se usa complemento a 2:  A - B = A + (~B) + 1   (11 bits, el MSB es el signo).
// Si el resultado es negativo, la magnitud se obtiene como complemento a 2 del resultado.
// Las entradas vienen de registros (data_regs) y las salidas se registran.
module sub_comp2 (
  input  logic       clk, reset,
  input  logic [9:0] a, b,
  output logic       neg,        // 1: resultado negativo
  output logic [9:0] mag );      // magnitud (0..999)

  logic [10:0] a_ext, b_inv, diff, diff_neg;
  logic        neg_next;
  logic [9:0]  mag_next;

  assign a_ext    = {1'b0, a};
  assign b_inv    = ~{1'b0, b};
  assign diff     = a_ext + b_inv + 11'd1;       // A + (~B) + 1
  assign diff_neg = ~diff + 11'd1;               // complemento a 2 del resultado

  always_comb begin
    neg_next = diff[10];
    if (diff[10])
      mag_next = diff_neg[9:0];
    else
      mag_next = diff[9:0];
  end

  // registro de salida
  always_ff @(posedge clk, posedge reset)
    if (reset) begin
      neg <= 1'b0;
      mag <= 10'd0;
    end
    else begin
      neg <= neg_next;
      mag <= mag_next;
    end
endmodule
