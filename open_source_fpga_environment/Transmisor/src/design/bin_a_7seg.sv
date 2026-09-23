// ============================================================
// Modulo 5.3: Codificacion binario a 7 segmentos
// EL-3307 Diseno Logico - Proyecto Corto I
// ------------------------------------------------------------
// Que es: el subsistema 5.3 del enunciado (codificacion binario
// a 7 segmentos), implementado dentro de la FPGA.
// Que hace: recibe una palabra de 4 bits (datos) y entrega el
// patron de segmentos que hay que prender en el display para
// mostrar ese numero en hexadecimal (0 a F).
//
// Mismo patron que el ejemplo "sevenseg" visto en clase
// (Harris & Harris): always_comb + case.
// seg = {g, f, e, d, c, b, a}, activo en ALTO (display de
// CATODO COMUN: el catodo compartido va a GND, y cada segmento
// a,b,c,d,e,f,g se enciende con un 1 desde la FPGA a traves de
// una resistencia de 330 ohm).
// ============================================================
 
module bin_a_7seg (
    input  logic [3:0] datos,
    output logic [6:0] seg      // {g,f,e,d,c,b,a}, activo en ALTO
);
 
    always_comb
        case (datos)
            // abc_defg (igual notacion que en clase)
            4'h0: seg = 7'b0111111;
            4'h1: seg = 7'b0000110;
            4'h2: seg = 7'b1011011;
            4'h3: seg = 7'b1001111;
            4'h4: seg = 7'b1100110;
            4'h5: seg = 7'b1101101;
            4'h6: seg = 7'b1111101;
            4'h7: seg = 7'b0000111;
            4'h8: seg = 7'b1111111;
            4'h9: seg = 7'b1101111;
            4'hA: seg = 7'b1110111;
            4'hB: seg = 7'b1111100;
            4'hC: seg = 7'b0111001;
            4'hD: seg = 7'b1011110;
            4'hE: seg = 7'b1111001;
            4'hF: seg = 7'b1110001;
            default: seg = 7'b0000000; // requerido
        endcase
 
endmodule
 