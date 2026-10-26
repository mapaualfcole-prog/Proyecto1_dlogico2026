// TOP: A - B con teclado hexadecimal y display de 4 digitos de 7 segmentos (catodo comun).
// Un solo reloj (27 MHz de la TangNano 9K).
//
//   teclado -> keypad_reader -> capture_fsm -> data_regs (A,B) -> sub_comp2 -> display_ctrl -> displays
//
// Teclas:  0-9 digitos | A = "-" (pasa a B) | B = "=" (calcula) | C = limpiar
module restador #(
  parameter DEB_N    = 21,   // debouncer: 2^(N-1)/27MHz = 39 ms
  parameter SCAN_N   = 10,   // barrido de columnas: 2^N ciclos por columna
  parameter REF_N    = 16,   // refresco del display: ~412 Hz de barrido completo
  parameter AN_INVERT = 0 )( // 1 si se maneja cada digito con un transistor NPN (enable activo en alto)
  input  logic       clk,
  input  logic       rst_n,      // boton, activo en bajo
  input  logic [3:0] rows,       // filas del teclado (pull-down externo)
  output logic [3:0] cols,       // columnas del teclado
  output logic [3:0] an,         // enable de digitos
  output logic [6:0] seg );      // segmentos a b c d e f g (activos en alto)

  // ---------------- sincronizacion del reset ----------------
  logic rst_ff1, rst_ff2;
  logic reset;

  always_ff @(posedge clk) begin
    rst_ff1 <= rst_n;
    rst_ff2 <= rst_ff1;
  end

  assign reset = ~rst_ff2;

  // ---------------- 4.1 teclado ----------------
  logic       key_valid;
  logic [3:0] key_code;

  keypad_reader #(.DEB_N(DEB_N), .SCAN_N(SCAN_N)) u_keypad (
    .clk       (clk),
    .reset     (reset),
    .rows      (rows),
    .cols      (cols),
    .key_valid (key_valid),
    .key_code  (key_code) );

  // ---------------- FSM de captura ----------------
  logic       clr, a_digit_en, b_digit_en;
  logic [1:0] disp_sel;

  capture_fsm u_fsm (
    .clk        (clk),
    .rst        (reset),
    .key_valid  (key_valid),
    .key_code   (key_code),
    .clr        (clr),
    .a_digit_en (a_digit_en),
    .b_digit_en (b_digit_en),
    .disp_sel   (disp_sel) );

  // ---------------- ruta de datos ----------------
  logic [9:0] a_reg, b_reg;

  data_regs u_regs (
    .clk        (clk),
    .reset      (reset),
    .clr        (clr),
    .a_digit_en (a_digit_en),
    .b_digit_en (b_digit_en),
    .digit      (key_code),
    .a_reg      (a_reg),
    .b_reg      (b_reg) );

  // ---------------- 4.2 resta ----------------
  logic       res_neg;
  logic [9:0] res_mag;

  sub_comp2 u_sub (
    .clk   (clk),
    .reset (reset),
    .a     (a_reg),
    .b     (b_reg),
    .neg   (res_neg),
    .mag   (res_mag) );

  // ---------------- seleccion de lo que se muestra ----------------
  logic       disp_neg;
  logic [9:0] disp_val;

  always_comb
    case (disp_sel)
      2'b00:   begin disp_neg = 1'b0;    disp_val = a_reg;   end
      2'b01:   begin disp_neg = 1'b0;    disp_val = b_reg;   end
      default: begin disp_neg = res_neg; disp_val = res_mag; end
    endcase

  // ---------------- 4.3 despliegue ----------------
  logic [3:0] an_disp;

  display_ctrl #(.REF_N(REF_N)) u_display (
    .clk   (clk),
    .reset (reset),
    .neg   (disp_neg),
    .value (disp_val),
    .an    (an_disp),
    .seg   (seg) );

  assign an = AN_INVERT ? ~an_disp : an_disp;
endmodule
