// Subsistema 4.1: lectura del teclado hexadecimal 4x4 con pull-down en las filas.
//  - Columnas: salidas, un contador de anillo (one-hot) las barre con un enable lento.
//  - Filas: entradas con pull-down externo, activas en alto cuando hay tecla.
//  - Si una fila se activa, el anillo se congela en esa columna.
//  - Las filas se sincronizan (2 FF) y "any_key" pasa por UNA instancia del DeBounce provisto.
//  - Un detector de flanco genera un pulso por tecla y se captura el codigo.
//
// Distribucion del teclado (fila, columna):
//         C0  C1  C2  C3
//   R0     1   2   3   A
//   R1     4   5   6   B
//   R2     7   8   9   C
//   R3     *   0   #   D
//
// Codigos de salida: digitos 0..9 -> 4'h0..4'h9, A..D -> 4'hA..4'hD, * -> 4'hE, # -> 4'hF
module keypad_reader #(
  parameter DEB_N  = 21,   // bits del debouncer: T = 2^(N-1)/27MHz  (N=21 -> 39 ms)
  parameter SCAN_N = 10    // paso del barrido: 2^SCAN_N ciclos por columna (10 -> 38 us)
)(
  input  logic       clk, reset,
  input  logic [3:0] rows,        // filas (asincronas)
  output logic [3:0] cols,        // columnas (barrido)
  output logic       key_valid,   // pulso de 1 ciclo por tecla
  output logic [3:0] key_code );

  // ---------------- sincronizador de filas (2 FF) ----------------
  logic [3:0] rows_ff1, rows_sync;

  always_ff @(posedge clk, posedge reset)
    if (reset) begin
      rows_ff1  <= 4'b0000;
      rows_sync <= 4'b0000;
    end
    else begin
      rows_ff1  <= rows;
      rows_sync <= rows_ff1;
    end

  logic any_key;
  assign any_key = |rows_sync;

  // ---------------- base de tiempo del barrido (enable, no es un reloj) ----------------
  logic [SCAN_N-1:0] scan_reg;
  logic              scan_tick;

  always_ff @(posedge clk, posedge reset)
    if (reset)
      scan_reg <= 0;
    else
      scan_reg <= scan_reg + 1;

  assign scan_tick = &scan_reg;

  // ---------------- contador de anillo de columnas ----------------
  logic [3:0] col_reg;

  always_ff @(posedge clk, posedge reset)
    if (reset)
      col_reg <= 4'b0001;
    else if (scan_tick && !any_key)           // si hay tecla, se congela
      col_reg <= {col_reg[2:0], col_reg[3]};

  assign cols = col_reg;

  // ---------------- debouncer provisto + detector de flanco ----------------
  logic db_level, db_tick;

  DeBounce #(.N(DEB_N)) u_debounce (
    .clk       (clk),
    .n_reset   (~reset),
    .button_in (any_key),
    .DB_out    (db_level) );

  edge_detect_gate u_edge (
    .clk   (clk),
    .reset (reset),
    .level (db_level),
    .tick  (db_tick) );

  // ---------------- codificacion fila/columna ----------------
  logic [1:0] row_idx, col_idx;
  logic       row_ok;                // solo una fila activa
  logic [3:0] code;

  always_comb begin
    row_ok = 1'b1;
    case (rows_sync)
      4'b0001: row_idx = 2'd0;
      4'b0010: row_idx = 2'd1;
      4'b0100: row_idx = 2'd2;
      4'b1000: row_idx = 2'd3;
      default: begin
        row_idx = 2'd0;
        row_ok  = 1'b0;
      end
    endcase
  end

  always_comb
    case (col_reg)
      4'b0001: col_idx = 2'd0;
      4'b0010: col_idx = 2'd1;
      4'b0100: col_idx = 2'd2;
      default: col_idx = 2'd3;
    endcase

  always_comb
    case ({row_idx, col_idx})
      4'b00_00: code = 4'h1;
      4'b00_01: code = 4'h2;
      4'b00_10: code = 4'h3;
      4'b00_11: code = 4'hA;
      4'b01_00: code = 4'h4;
      4'b01_01: code = 4'h5;
      4'b01_10: code = 4'h6;
      4'b01_11: code = 4'hB;
      4'b10_00: code = 4'h7;
      4'b10_01: code = 4'h8;
      4'b10_10: code = 4'h9;
      4'b10_11: code = 4'hC;
      4'b11_00: code = 4'hE;   // *
      4'b11_01: code = 4'h0;
      4'b11_10: code = 4'hF;   // #
      default : code = 4'hD;
    endcase

  // ---------------- registros de salida ----------------
  always_ff @(posedge clk, posedge reset)
    if (reset) begin
      key_valid <= 1'b0;
      key_code  <= 4'h0;
    end
    else begin
      key_valid <= db_tick & row_ok;
      if (db_tick & row_ok)
        key_code <= code;
    end
endmodule
