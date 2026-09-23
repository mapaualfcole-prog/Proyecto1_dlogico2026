// ============================================================
// Testbench basico: generador_error
// EL-3307 Diseno Logico - Proyecto Corto I
// ------------------------------------------------------------
// Que es: banco de pruebas (testbench) del subsistema 5.4.
// Que hace: prueba varios casos (sin error, un error en distintas
// posiciones, y dos errores a la vez) y compara la salida contra
// el resultado que se calculo aparte a mano/con script.
//
// Compilar con:
//   iverilog -Wall -g2012 -o sim_error generador_error.sv generador_error_tb.sv
//   vvp sim_error
// ============================================================

`timescale 1ns/1ps

module generador_error_tb;

    // Senales conectadas al modulo bajo prueba (dut)
    logic [7:0] pal_cod;
    logic [2:0] pos_err1;
    logic [2:0] pos_err2;
    logic [7:0] pal_err;

    integer errores; // cuenta cuantos casos fallaron
    integer caso;    // numero de caso actual (solo para el mensaje)

    generador_error dut (
        .pal_cod (pal_cod),
        .pos_err1(pos_err1),
        .pos_err2(pos_err2),
        .pal_err (pal_err)
    );

    // Tarea (task) que aplica un caso de prueba y revisa el resultado.
    // No usa "automatic" porque los casos se llaman uno despues del
    // otro (nunca al mismo tiempo), asi que no hace falta.
    task probar;
        input [7:0] cod;
        input [2:0] p1;
        input [2:0] p2;
        input [7:0] esperado;
        begin
            caso = caso + 1;
            pal_cod  = cod;
            pos_err1 = p1;
            pos_err2 = p2;
            #10;
            if (pal_err !== esperado) begin
                $display("FALLO caso %0d: pal_cod=%b p1=%0d p2=%0d -> pal_err=%b (esperado=%b)",
                          caso, cod, p1, p2, pal_err, esperado);
                errores = errores + 1;
            end else begin
                $display("OK    caso %0d: pal_cod=%b p1=%0d p2=%0d -> pal_err=%b",
                          caso, cod, p1, p2, pal_err);
            end
        end
    endtask

    initial begin
        // Estas dos lineas generan el archivo .vcd que despues
        // abre "make wv" (GTKWave) para ver las formas de onda.
        $dumpfile("generador_error_tb.vcd");
        $dumpvars(0, generador_error_tb);

        errores = 0;
        caso = 0;

        // Caso 1: sin error, la salida debe ser igual a la entrada
        probar(8'b01010101, 3'd0, 3'd0, 8'b01010101);

        // Caso 2: un solo error en la posicion 1 (bit 0)
        probar(8'b00000000, 3'd1, 3'd0, 8'b00000001);

        // Caso 3: un solo error en la posicion 7 (bit 6)
        probar(8'b00000000, 3'd7, 3'd0, 8'b01000000);

        // Caso 4: un solo error en la posicion 4 (bit 3), por el segundo canal
        probar(8'b00000000, 3'd0, 3'd4, 8'b00001000);

        // Caso 5: dos errores al mismo tiempo, posiciones 2 y 5
        probar(8'b00000000, 3'd2, 3'd5, 8'b00010010);

        // Caso 6: doble error sobre una palabra que no es todo ceros
        probar(8'b01111111, 3'd3, 3'd6, 8'b01011011);

        // Resumen final
        if (errores == 0)
            $display("\n*** TODAS LAS PRUEBAS PASARON ***");
        else
            $display("\n*** %0d PRUEBA(S) FALLARON ***", errores);

        $finish;
    end

endmodule
