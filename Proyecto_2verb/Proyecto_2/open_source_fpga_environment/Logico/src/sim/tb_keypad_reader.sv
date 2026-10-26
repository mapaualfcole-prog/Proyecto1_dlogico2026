// Testbench del subsistema 4.1 (lectura del teclado 4x4, filas con pull-down).
// Presiona las 16 teclas con rebotes y verifica un solo pulso key_valid y el codigo correcto.
// Tambien verifica que una tecla mantenida mucho tiempo genere un solo pulso.
`timescale 1 ns / 100 ps

module tb_keypad_reader;

  logic       clk, reset;
  logic [3:0] rows, cols;
  logic       key_valid;
  logic [3:0] key_code;

  logic       key_down;
  logic [1:0] krow, kcol;

  integer errors, checks;
  integer pulses;
  logic [3:0] last_code;
  integer r, c;

  keypad_reader #(.DEB_N(6), .SCAN_N(3)) dut (
    .clk(clk), .reset(reset), .rows(rows), .cols(cols),
    .key_valid(key_valid), .key_code(key_code));

  // teclado con pull-down
  assign rows = (key_down && cols[kcol]) ? (4'b0001 << krow) : 4'b0000;

  initial clk = 1'b0;
  always #18.5 clk = ~clk;

  // contador de pulsos
  always @(posedge clk)
    if (key_valid) begin
      pulses    = pulses + 1;
      last_code = key_code;
    end

  function [3:0] exp_code(input integer rr, input integer cc);
    case (rr * 4 + cc)
      0:  exp_code = 4'h1;  1:  exp_code = 4'h2;  2:  exp_code = 4'h3;  3:  exp_code = 4'hA;
      4:  exp_code = 4'h4;  5:  exp_code = 4'h5;  6:  exp_code = 4'h6;  7:  exp_code = 4'hB;
      8:  exp_code = 4'h7;  9:  exp_code = 4'h8;  10: exp_code = 4'h9;  11: exp_code = 4'hC;
      12: exp_code = 4'hE;  13: exp_code = 4'h0;  14: exp_code = 4'hF;  default: exp_code = 4'hD;
    endcase
  endfunction

  // pulsacion con rebotes; hold = ciclos con la tecla estable
  task press(input integer rr, input integer cc, input integer hold);
    begin
      krow = rr; kcol = cc;
      repeat (3) begin
        key_down = 1'b1; repeat (3) @(negedge clk);
        key_down = 1'b0; repeat (2) @(negedge clk);
      end
      key_down = 1'b1;
      repeat (hold) @(negedge clk);
      repeat (3) begin
        key_down = 1'b0; repeat (2) @(negedge clk);
        key_down = 1'b1; repeat (3) @(negedge clk);
      end
      key_down = 1'b0;
      repeat (100) @(negedge clk);
    end
  endtask

  task check_key(input integer rr, input integer cc, input integer hold);
    begin
      pulses = 0; last_code = 4'hx;
      press(rr, cc, hold);
      checks = checks + 1;
      if (pulses == 1 && last_code === exp_code(rr, cc))
        $display("PASS  fila %0d col %0d -> codigo %h (hold %0d)", rr, cc, last_code, hold);
      else begin
        errors = errors + 1;
        $display("FAIL  fila %0d col %0d : pulsos=%0d codigo=%h esperado=%h",
                 rr, cc, pulses, last_code, exp_code(rr, cc));
      end
    end
  endtask

  initial begin
    $dumpfile("tb_keypad_reader.vcd");
    $dumpvars(0, tb_keypad_reader);
    errors = 0; checks = 0; pulses = 0; last_code = 4'h0;
    key_down = 1'b0; krow = 0; kcol = 0;
    reset = 1'b1;
    repeat (6) @(negedge clk);
    reset = 1'b0;
    repeat (100) @(negedge clk);       // el debouncer termina su arranque

    // las 16 teclas
    for (r = 0; r < 4; r = r + 1)
      for (c = 0; c < 4; c = c + 1)
        check_key(r, c, 300);

    // tecla mantenida mucho tiempo: un solo pulso
    check_key(1, 1, 3000);

    $display("--------------------------------------------------");
    if (errors == 0) $display("tb_keypad_reader: TODAS LAS PRUEBAS PASARON (%0d checks)", checks);
    else             $display("tb_keypad_reader: FALLARON %0d de %0d checks", errors, checks);
    $finish;
  end

  initial begin
    #20_000_000;
    $display("TIMEOUT");
    $finish;
  end
endmodule
