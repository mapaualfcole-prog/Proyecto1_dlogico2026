// Testbench del subsistema 4.2 (resta en complemento a 2).
// Compara contra A-B calculado en el testbench (aqui si se permite el operador "-").
`timescale 1 ns / 100 ps

module tb_sub_comp2;

  logic       clk, reset;
  logic [9:0] a, b;
  logic       neg;
  logic [9:0] mag;

  integer errors, checks, i;
  integer seed;

  sub_comp2 dut (.clk(clk), .reset(reset), .a(a), .b(b), .neg(neg), .mag(mag));

  initial clk = 1'b0;
  always #18.5 clk = ~clk;

  task check(input integer va, input integer vb);
    integer exp_mag, exp_neg;
    begin
      a = va; b = vb;
      @(negedge clk);          // la salida esta registrada: queda lista en el siguiente ciclo
      @(negedge clk);
      if (va >= vb) begin exp_neg = 0; exp_mag = va - vb; end
      else          begin exp_neg = 1; exp_mag = vb - va; end
      checks = checks + 1;
      if (neg !== exp_neg[0] || mag !== exp_mag[9:0]) begin
        errors = errors + 1;
        $display("FAIL  %0d - %0d : obtenido neg=%b mag=%0d, esperado neg=%0d mag=%0d",
                 va, vb, neg, mag, exp_neg, exp_mag);
      end
    end
  endtask

  initial begin
    $dumpfile("tb_sub_comp2.vcd");
    $dumpvars(0, tb_sub_comp2);
    errors = 0; checks = 0; seed = 7;
    a = 0; b = 0;
    reset = 1'b1;
    repeat (3) @(negedge clk);
    reset = 1'b0;

    // casos de borde
    check(0, 0);
    check(999, 0);
    check(0, 999);
    check(999, 999);
    check(1, 0);
    check(0, 1);
    check(123, 45);
    check(12, 500);
    check(250, 250);
    check(7, 9);
    check(100, 99);
    check(99, 100);

    // casos aleatorios en 0..999
    for (i = 0; i < 2000; i = i + 1)
      check($unsigned($random(seed)) % 1000, $unsigned($random(seed)) % 1000);

    $display("--------------------------------------------------");
    if (errors == 0) $display("tb_sub_comp2: TODAS LAS PRUEBAS PASARON (%0d checks)", checks);
    else             $display("tb_sub_comp2: FALLARON %0d de %0d checks", errors, checks);
    $finish;
  end
endmodule
