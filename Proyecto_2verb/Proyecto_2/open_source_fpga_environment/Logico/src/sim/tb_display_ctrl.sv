// Testbench del subsistema 4.3 (BCD + multiplexado de 4 digitos de 7 segmentos).
// Necesita bcdtable.txt en el directorio donde se ejecuta la simulacion (build/).
`timescale 1 ns / 100 ps

module tb_display_ctrl;

  logic       clk, reset;
  logic       neg;
  logic [9:0] value;
  logic [3:0] an;
  logic [6:0] seg;

  integer errors, checks;

  display_ctrl #(.REF_N(6)) dut (
    .clk(clk), .reset(reset), .neg(neg), .value(value), .an(an), .seg(seg));

  initial clk = 1'b0;
  always #18.5 clk = ~clk;

  // lo que muestra cada digito
  logic [6:0] shown [0:3];
  always @(negedge clk) begin
    if (an[0] == 1'b0) shown[0] <= seg;
    if (an[1] == 1'b0) shown[1] <= seg;
    if (an[2] == 1'b0) shown[2] <= seg;
    if (an[3] == 1'b0) shown[3] <= seg;
  end

  // an debe tener siempre exactamente un digito habilitado (activo en bajo)
  integer bad_an;
  initial bad_an = 0;
  always @(negedge clk)
    if (!reset && an !== 4'b1110 && an !== 4'b1101 && an !== 4'b1011 && an !== 4'b0111)
      bad_an = bad_an + 1;

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
      4'hE:    enc = 7'b0000001;
      default: enc = 7'b0000000;
    endcase
  endfunction

  task show(input integer v, input integer n);
    integer d2, d1, d0;
    reg [6:0] e3, e2, e1, e0;
    begin
      value = v; neg = n;
      repeat (150) @(negedge clk);
      d2 = v / 100; d1 = (v / 10) % 10; d0 = v % 10;
      e3 = n ? enc(4'hE) : enc(4'hF);
      e2 = (d2 == 0) ? enc(4'hF) : enc(d2);
      e1 = (d2 == 0 && d1 == 0) ? enc(4'hF) : enc(d1);
      e0 = enc(d0);
      checks = checks + 1;
      if (shown[3] === e3 && shown[2] === e2 && shown[1] === e1 && shown[0] === e0)
        $display("PASS  %0s%0d", n ? "-" : "", v);
      else begin
        errors = errors + 1;
        $display("FAIL  %0s%0d", n ? "-" : "", v);
        $display("      obtenido d3=%b d2=%b d1=%b d0=%b", shown[3], shown[2], shown[1], shown[0]);
        $display("      esperado d3=%b d2=%b d1=%b d0=%b", e3, e2, e1, e0);
      end
    end
  endtask

  initial begin
    $dumpfile("tb_display_ctrl.vcd");
    $dumpvars(0, tb_display_ctrl);
    errors = 0; checks = 0;
    value = 0; neg = 0;
    reset = 1'b1;
    repeat (4) @(negedge clk);
    reset = 1'b0;

    show(0,   0);
    show(7,   0);
    show(45,  0);
    show(100, 0);
    show(123, 0);
    show(909, 0);
    show(999, 0);
    show(2,   1);
    show(488, 1);
    show(999, 1);

    checks = checks + 1;
    if (bad_an != 0) begin
      errors = errors + 1;
      $display("FAIL  an tuvo %0d valores no validos", bad_an);
    end else
      $display("PASS  an siempre habilita un solo digito");

    $display("--------------------------------------------------");
    if (errors == 0) $display("tb_display_ctrl: TODAS LAS PRUEBAS PASARON (%0d checks)", checks);
    else             $display("tb_display_ctrl: FALLARON %0d de %0d checks", errors, checks);
    $finish;
  end
endmodule
