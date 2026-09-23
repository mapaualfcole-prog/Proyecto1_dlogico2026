// ============================================================
// Modulo 5.4: Generador de error
// EL-3307 Diseno Logico - Proyecto Corto I
// ------------------------------------------------------------
// Que es: el subsistema 5.4 del enunciado (generador de error),
// implementado dentro de la FPGA.
// Que hace: recibe la palabra codificada de 8 bits y, segun la
// posicion que indiquen los switches de error, voltea (invierte)
// uno o dos bits de esa palabra antes de transmitirla. Si el
// switch de una posicion esta en 000, no cambia nada.
//
// Usa el mismo truco de decodificador visto en la diapositiva
// "Implementing combinational blocks - Decoder":
//      wire [m-1:0] b = 1 << a;
// para convertir la posicion binaria en una mascara one-hot,
// y el operador condicional (?:) visto en "Conditional
// assignment" para manejar el caso "sin error" (pos = 0).
//
// pal_cod[6:0] -> posiciones Hamming 1..7 (pal_cod[0]=pos1, ...,
//                  pal_cod[6]=pos7)
// pal_cod[7]   -> bit de paridad DED (octavo bit)
//
// pos_err1, pos_err2: 000 = sin error, 001..111 = posicion 1..7
// ============================================================
 
module generador_error (
    input  logic [7:0] pal_cod,
    input  logic [2:0] pos_err1,
    input  logic [2:0] pos_err2,
    output logic [7:0] pal_err
);
 
    // Decodificador tipo "1 << a", igual al visto en clase,
    // pero con seleccion de "sin error" via operador ternario.
    logic [7:0] mask1, mask2;
 
    assign mask1 = (pos_err1 == 3'd0) ? 8'd0 : (8'd1 << (pos_err1 - 3'd1));
    assign mask2 = (pos_err2 == 3'd0) ? 8'd0 : (8'd1 << (pos_err2 - 3'd1));
 
    // Inversion (XOR) de los bits marcados por cualquiera de las
    // dos mascaras: soporta un error, dos errores, o ninguno.
    assign pal_err = pal_cod ^ (mask1 | mask2);
 
endmodule
 