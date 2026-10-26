// Ruta de datos de captura: registros A y B (binario, 10 bits, 0..999).
// Al llegar un digito:  valor = valor*10 + digito, con valor*10 = (valor<<3) + (valor<<1).
// Si el valor ya es >= 100 no se acepta otro digito (maximo 3 digitos).
module data_regs (
  input  logic       clk, reset,
  input  logic       clr,
  input  logic       a_digit_en, b_digit_en,
  input  logic [3:0] digit,
  output logic [9:0] a_reg, b_reg );

  logic [9:0] a_next, b_next;
  logic       a_full, b_full;
  logic [9:0] digit_ext;

  assign digit_ext = {6'b000000, digit};
  assign a_full = (a_reg > 10'd99);
  assign b_full = (b_reg > 10'd99);

  // next-state logic
  always_comb begin
    a_next = a_reg;
    b_next = b_reg;
    if (a_digit_en && !a_full)
      a_next = (a_reg << 3) + (a_reg << 1) + digit_ext;
    if (b_digit_en && !b_full)
      b_next = (b_reg << 3) + (b_reg << 1) + digit_ext;
  end

  // registers
  always_ff @(posedge clk, posedge reset)
    if (reset) begin
      a_reg <= 10'd0;
      b_reg <= 10'd0;
    end
    else if (clr) begin
      a_reg <= 10'd0;
      b_reg <= 10'd0;
    end
    else begin
      a_reg <= a_next;
      b_reg <= b_next;
    end
endmodule
