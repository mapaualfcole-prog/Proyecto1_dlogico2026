// ============================================================
// top_transmisor.sv
// Top del lado FPGA del transmisor, para probar SIN el receptor.
//
// Que es: modulo "top" REAL para programar la FPGA del transmisor
// (a diferencia de top_transmisor_sim.sv, que es solo para simular).
// Que hace: conecta 5.3 y 5.4 (los unicos subsistemas que van
// dentro de la FPGA) con los pines fisicos de entrada y salida.
//
// La codificacion Hamming(7,4) + paridad DED (puntos 5.1 y 5.2)
// se hace FISICAMENTE con circuitos 74HCXX en la protoboard, por
// lo que "pal_cod" entra a la FPGA como 8 pines de entrada reales
// (cableados desde la salida de esos ICs), NO se calcula aqui.
//
// Este top conecta unicamente los subsistemas que SI van en la
// FPGA: 5.3 (bin_a_7seg) y 5.4 (generador_error).
// ============================================================
 
module top (
    // Switches de datos (4 bits) - van tambien al circuito fisico
    // de codificacion Hamming, y aqui solo se usan para mostrar
    // la palabra original en el 7 segmentos (5.3)
    input  logic [3:0] datos,
 
    // Palabra ya codificada (8 bits), viene FISICAMENTE de los
    // 74HCXX en la protoboard (5.1 codificador Hamming + 5.2 DED)
    input  logic [7:0] pal_cod,
 
    // Switches de posicion de error (5.4)
    input  logic [2:0] pos_err1,
    input  logic [2:0] pos_err2,
 
    // Salida: palabra original en 7 segmentos (para verificar
    // visualmente que los switches de datos se leen bien)
    output logic [6:0] seg,
 
    // Salida: palabra codificada final (con error insertado si
    // aplica), a LEDs, para verificarla a mano sin el receptor
    output logic [7:0] pal_err
);
 
    bin_a_7seg u_bin_a_7seg (
        .datos(datos),
        .seg  (seg)
    );
 
    generador_error u_generador_error (
        .pal_cod (pal_cod),
        .pos_err1(pos_err1),
        .pos_err2(pos_err2),
        .pal_err (pal_err)
    );
 
endmodule
 