// ============================================================
// Testbench basico: bin_a_7seg
// EL-3307 Diseno Logico - Proyecto Corto I
// ------------------------------------------------------------
// Que es: banco de pruebas (testbench) del subsistema 5.3.
// Que hace: prueba los 16 valores posibles de "datos" (0 a F) y
// compara la salida "seg" contra el valor que debería salir,
// para confirmar que el decodificador esta bien.
//
// Compilar con:
//   iverilog -Wall -g2012 -o sim_7seg bin_a_7seg.sv bin_a_7seg_tb.sv
//   vvp sim_7seg
// ============================================================
 
`timescale 1ns/1ps
 
module bin_a_7seg_tb;
 
    // Senales que se conectan al modulo que se esta probando (dut)
    logic [3:0] datos;
    logic [6:0] seg;
 
    // Contadores simples para el resumen final
    integer errores;
    integer i;
 
    // Tabla con el valor de "seg" que se espera para cada digito
    logic [6:0] esperado [0:15];
 
    // dut = "device under test", el modulo que estamos probando
    bin_a_7seg dut (
        .datos(datos),
        .seg  (seg)
    );
 
    initial begin
        // Estas dos lineas son las que permiten generar el archivo
        // .vcd que despues abre "make wv" (GTKWave) para ver las
        // formas de onda de las senales.
        $dumpfile("bin_a_7seg_tb.vcd");
        $dumpvars(0, bin_a_7seg_tb);
 
        // Se llena la tabla de valores esperados.
        // Activo en ALTO porque el display es de catodo comun
        // (1 = segmento encendido), por eso ya NO se invierte con ~.
        esperado[0]  = 7'b0111111;
        esperado[1]  = 7'b0000110;
        esperado[2]  = 7'b1011011;
        esperado[3]  = 7'b1001111;
        esperado[4]  = 7'b1100110;
        esperado[5]  = 7'b1101101;
        esperado[6]  = 7'b1111101;
        esperado[7]  = 7'b0000111;
        esperado[8]  = 7'b1111111;
        esperado[9]  = 7'b1101111;
        esperado[10] = 7'b1110111;
        esperado[11] = 7'b1111100;
        esperado[12] = 7'b0111001;
        esperado[13] = 7'b1011110;
        esperado[14] = 7'b1111001;
        esperado[15] = 7'b1110001;
 
        errores = 0;
 
        // Se prueban los 16 digitos, uno por uno
        for (i = 0; i < 16; i = i + 1) begin
            datos = i[3:0];
            #10; // se espera a que la salida se acomode
 
            if (seg !== esperado[i]) begin
                $display("FALLO: datos=%h  seg=%b  esperado=%b", datos, seg, esperado[i]);
                errores = errores + 1;
            end else begin
                $display("OK   : datos=%h  seg=%b", datos, seg);
            end
        end
 
        // Resumen final
        if (errores == 0)
            $display("\n*** TODAS LAS PRUEBAS PASARON ***");
        else
            $display("\n*** %0d PRUEBA(S) FALLARON ***", errores);
 
        $finish;
    end
 
endmodule
 