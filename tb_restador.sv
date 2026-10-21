// Testbench del sistema completo: teclado -> resta -> display.
// Modela un teclado 4x4 con pull-down y rebotes, y verifica lo que muestran los 4 digitos.
// Se usan parametros pequenos (DEB_N, SCAN_N, REF_N) para acortar la simulacion.
`timescale 1 ns / 100 ps

module tb_restador;

  // ---------------- senales ----------------
  logic       clk, rst_n;
  logic [3:0] rows, cols, an;
  logic [6:0] seg;

  // modelo del teclado
  logic       key_down;
  logic [1:0] krow, kcol;

  integer errors, checks;

  // ---------------- DUT ----------------
  restador #(.DEB_N(6), .SCAN_N(3), .REF_N(6), .AN_INVERT(0)) dut (
    .clk   (clk),
    .rst_n (rst_n),
    .rows  (rows),
    .cols  (cols),
    .an    (an),
    .seg   (seg) );

  // ---------------- teclado con pull-down: fila en alto solo si la tecla une su fila con la columna activa ----------------
  assign rows = (key_down && cols[kcol]) ? (4'b0001 << krow) : 4'b0000;

  // ---------------- reloj ~27 MHz ----------------
  initial clk = 1'b0;
  always #18.5 clk = ~clk;

  // ---------------- captura de lo que muestra cada digito ----------------
  logic [6:0] shown [0:3];

  always @(negedge clk) begin
    if (an[0] == 1'b0) shown[0] <= seg;
    if (an[1] == 1'b0) shown[1] <= seg;
    if (an[2] == 1'b0) shown[2] <= seg;
    if (an[3] == 1'b0) shown[3] <= seg;
  end

  // ---------------- codificacion esperada (activa en alto) ----------------
  function [6:0] enc(input [3:0] h);
    case (h)
      4'd0:    enc = 7'b1111110;
      4'd1:    enc = 7'b0110000;
      4'd2:    enc = 7'b1101101;
      4'd3:    enc = 7'b1111001;
      4'd4:    enc = 7'b0110011;
      4'd5:    enc = 7'b1011011;
      4'd6:    enc = 7'b1011111;
      4'd7:    enc = 7'b1110000;
      4'd8:    enc = 7'b1111111;
      4'd9:    enc = 7'b1111011;
      4'hE:    enc = 7'b0000001;   // menos
      default: enc = 7'b0000000;   // apagado
    endcase
  endfunction

  // ---------------- pulsar una tecla (con rebotes al presionar y al soltar) ----------------
  task press_key(input [1:0] r, input [1:0] c);
    begin
      krow = r;
      kcol = c;
      // rebotes al presionar
      repeat (3) begin
        key_down = 1'b1; repeat (3) @(negedge clk);
        key_down = 1'b0; repeat (2) @(negedge clk);
      end
      key_down = 1'b1;
      repeat (300) @(negedge clk);       // tecla estable
      // rebotes al soltar
      repeat (3) begin
        key_down = 1'b0; repeat (2) @(negedge clk);
        key_down = 1'b1; repeat (3) @(negedge clk);
      end
      key_down = 1'b0;
      repeat (100) @(negedge clk);       // pausa para que el debouncer vea la liberacion
    end
  endtask

  task press_digit(input integer d);
    begin
      if (d == 0) press_key(2'd3, 2'd1);
      else        press_key((d - 1) / 3, (d - 1) % 3);
    end
  endtask

  task press_minus;  press_key(2'd0, 2'd3); endtask   // tecla A
  task press_equal;  press_key(2'd1, 2'd3); endtask   // tecla B
  task press_clear;  press_key(2'd2, 2'd3); endtask   // tecla C

  // ---------------- verificacion del display ----------------
  task check_display(input integer value, input integer is_neg, input [8*24-1:0] name);
    integer d2, d1, d0;
    reg [6:0] e3, e2, e1, e0;
    begin
      repeat (150) @(negedge clk);        // varios barridos completos del multiplexado
      d2 = value / 100;
      d1 = (value / 10) % 10;
      d0 = value % 10;
      e3 = is_neg ? enc(4'hE) : enc(4'hF);
      e2 = (d2 == 0) ? enc(4'hF) : enc(d2);
      e1 = (d2 == 0 && d1 == 0) ? enc(4'hF) : enc(d1);
      e0 = enc(d0);
      checks = checks + 1;
      if (shown[3] === e3 && shown[2] === e2 && shown[1] === e1 && shown[0] === e0)
        $display("%t  PASS  %0s  -> %0s%0d", $time, name, is_neg ? "-" : "", value);
      else begin
        errors = errors + 1;
        $display("%t  FAIL  %0s  esperado %0s%0d", $time, name, is_neg ? "-" : "", value);
        $display("          segs obtenidos  d3=%b d2=%b d1=%b d0=%b", shown[3], shown[2], shown[1], shown[0]);
        $display("          segs esperados  d3=%b d2=%b d1=%b d0=%b", e3, e2, e1, e0);
      end
    end
  endtask

  // ---------------- estimulo ----------------
  initial begin
    $dumpfile("tb_restador.vcd");
    $dumpvars(0, tb_restador);
    $display("%t << Starting the Simulation >>", $time);

    errors = 0; checks = 0;
    rst_n = 1'b0; key_down = 1'b0; krow = 2'd0; kcol = 2'd0;
    repeat (10) @(negedge clk);
    rst_n = 1'b1;
    repeat (20) @(negedge clk);

    check_display(0, 0, "reset: muestra 0");

    // ---- caso 1: 123 - 45 = 78 ----
    press_digit(1); press_digit(2); press_digit(3);
    check_display(123, 0, "A = 123");
    press_digit(9);                                      // cuarto digito se ignora
    check_display(123, 0, "4to digito ignorado");
    press_minus;
    check_display(0, 0, "pasa a B (muestra 0)");
    press_digit(4); press_digit(5);
    check_display(45, 0, "B = 45");
    press_equal;
    check_display(78, 0, "123 - 45 = 78");

    // ---- caso 2: 12 - 500 = -488 ----
    press_clear;
    check_display(0, 0, "clear");
    press_digit(1); press_digit(2);
    press_minus;
    press_digit(5); press_digit(0); press_digit(0);
    press_equal;
    check_display(488, 1, "12 - 500 = -488");

    // ---- caso 3: 250 - 250 = 0 ----
    press_clear;
    press_digit(2); press_digit(5); press_digit(0);
    press_minus;
    press_digit(2); press_digit(5); press_digit(0);
    press_equal;
    check_display(0, 0, "250 - 250 = 0");

    // ---- caso 4: 7 - 9 = -2 ----
    press_clear;
    press_digit(7);
    press_minus;
    press_digit(9);
    press_equal;
    check_display(2, 1, "7 - 9 = -2");

    // ---- caso 5: 999 - 007 = 992 (los ceros iniciales no consumen digitos: 0 0 7 -> 7) ----
    press_clear;
    press_digit(9); press_digit(9); press_digit(9);
    press_minus;
    press_digit(0); press_digit(0); press_digit(7);
    press_equal;
    check_display(992, 0, "999 - 007 = 992");

    $display("--------------------------------------------------");
    if (errors == 0) $display("TODAS LAS PRUEBAS PASARON (%0d checks)", checks);
    else             $display("FALLARON %0d de %0d checks", errors, checks);
    $finish;
  end

  // watchdog
  initial begin
    #5_000_000;
    $display("TIMEOUT");
    $finish;
  end

endmodule
