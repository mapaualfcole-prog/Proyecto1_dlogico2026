`timescale 1ns/1ps
module testbench;
    logic clk = 0;
    logic reset, cargar, negativo;
    logic [9:0] magnitud;
    logic [7:0] segmentos_cc;
    logic [3:0] digitos_cc;
    integer errores = 0;

    // En hardware: N_REFRESH=16. N_REFRESH=5 acelera simulacion.
    display_43 #(.N_REFRESH(5)) DUT (
        .clk(clk), .reset(reset), .cargar(cargar),
        .magnitud(magnitud), .negativo(negativo),
        .segmentos_cc(segmentos_cc), .digitos_cc(digitos_cc)
    );

    // Aprox. 27 MHz (36. ... ns por ciclo).
    always #18.519 clk = ~clk;

    // Patrones ACTIVOS EN ALTO para segmentos[6:0].
    function automatic [6:0] patron_cc(input logic [3:0] digito);
        case(digito)
            4'd0: patron_cc = 7'b1111110;
            4'd1: patron_cc = 7'b0110000;
            4'd2: patron_cc = 7'b1101101;
            4'd3: patron_cc = 7'b1111001;
            4'd4: patron_cc = 7'b0110011;
            4'd5: patron_cc = 7'b1011011;
            4'd6: patron_cc = 7'b1011111;
            4'd7: patron_cc = 7'b1110000;
            4'd8: patron_cc = 7'b1111111;
            4'd9: patron_cc = 7'b1111011;
            4'hA: patron_cc = 7'b0000001; // menos
            default: patron_cc = 7'b0000000; // blanco
        endcase
    endfunction

    task automatic probar(
        input logic [9:0] valor,
        input logic signo,
        input logic [3:0] d3, d2, d1, d0
    );
        logic [3:0] vistos;
        logic [3:0] esperado;
        integer i;
        begin
            @(negedge clk);
            magnitud = valor;
            negativo = signo;
            cargar = 1'b1;
            @(negedge clk);
            cargar = 1'b0;
            repeat(4) @(negedge clk); // esperar a los registros
            vistos = 4'b0000;
            // N=5: ciclo completo de multiplexacion cada 32 relojes.
            for (i = 0; i < 68; i = i+1) begin
                @(negedge clk);
                case (digitos_cc)
                    4'b0000: begin
                        // Un ciclo de apagado entre digitos.
                        if (segmentos_cc !== 8'h00) begin
                            $display("ERROR: segmentos no apagados en blanco");
                            errores = errores + 1;
                        end
                    end
                    4'b0001: begin esperado=d0; vistos[0]=1; end
                    4'b0010: begin esperado=d1; vistos[1]=1; end
                    4'b0100: begin esperado=d2; vistos[2]=1; end
                    4'b1000: begin esperado=d3; vistos[3]=1; end
                    default: begin
                        esperado=4'hB;
                        $display("ERROR: mas de un digito activo: %b",digitos_cc);
                        errores = errores + 1;
                    end
                endcase
                if (digitos_cc != 0) begin
                    if (segmentos_cc !== {1'b0,patron_cc(esperado)}) begin
                        $display("ERROR %0d negativo=%b seleccion=%b segmentos=%b esperado=%b",
                            valor, signo, digitos_cc, segmentos_cc,
                            {1'b0,patron_cc(esperado)});
                        errores = errores + 1;
                    end
                end
            end
            if (vistos !== 4'b1111) begin
                $display("ERROR: no se habilitaron los cuatro digitos: %b", vistos);
                errores = errores + 1;
            end
            else $display("Comprobado: magnitud=%0d negativo=%b", valor, signo);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0,testbench);
        reset = 1;
        cargar = 0;
        magnitud = 0;
        negativo = 0;
        repeat(3) @(negedge clk);
        reset = 0;
        probar(10'd0,   0, 4'hB,4'hB,4'hB,4'd0);
        probar(10'd0,   1, 4'hB,4'hB,4'hB,4'd0); // no mostrar -0
        probar(10'd7,   0, 4'hB,4'hB,4'hB,4'd7);
        probar(10'd25,  0, 4'hB,4'hB,4'd2,4'd5);
        probar(10'd257, 0, 4'hB,4'd2,4'd5,4'd7);
        probar(10'd134, 1, 4'hA,4'd1,4'd3,4'd4);
        probar(10'd999, 1, 4'hA,4'd9,4'd9,4'd9);
        probar(10'd999, 0, 4'hB,4'd9,4'd9,4'd9);
        if (errores == 0) $display("TODAS LAS PRUEBAS PASARON");
        else $fatal(1, "Se encontraron %0d errores", errores);
        $finish;
    end
endmodule
