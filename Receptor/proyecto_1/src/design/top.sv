module top(

    input logic clk,

    input logic btn1,


    input logic [7:0] palabra_rx,

    input logic [2:0] sindrome_cmos,

    input logic paridad_cmos,


    output logic [5:0] led,

    output logic [6:0] display,


    output logic seg_enable1,

    output logic seg_enable2

);


//--------------------------------
// Señales internas
//--------------------------------

logic [6:0] palabra;

logic [6:0] palabra_corregida;


logic [3:0] dato_corregido;


logic [3:0] dato_recibido;


logic [3:0] numero_display;


logic DED;



//--------------------------------
// Quitar bit de paridad
//
// palabra_rx:
//
// i3 i2 i1 c2 i0 c1 c0 P
//
// palabra:
//
// i3 i2 i1 c2 i0 c1 c0
//--------------------------------

assign palabra = palabra_rx[7:1];



//--------------------------------
// Corrector SEC
//--------------------------------

corrector_sec SEC(

    .palabra(palabra),

    .sindrome(sindrome_cmos),

    .corregida(palabra_corregida)

);



//--------------------------------
// Extraer información corregida
//
// palabra_corregida:
//
// i3 i2 i1 c2 i0 c1 c0
//--------------------------------

assign dato_corregido = {

    palabra_corregida[6], // i3

    palabra_corregida[5], // i2

    palabra_corregida[4], // i1

    palabra_corregida[2]  // i0

};



//--------------------------------
// Extraer información recibida
// SIN corregir
//
// palabra_rx:
//
// i3 i2 i1 c2 i0 c1 c0 P
//--------------------------------

assign dato_recibido = {

    palabra_rx[7], // i3

    palabra_rx[6], // i2

    palabra_rx[5], // i1

    palabra_rx[3]  // i0

};



//--------------------------------
// Detector DED
//--------------------------------

detector_ded DED_MODULE(

    .sindrome(sindrome_cmos),

    .paridad_cmos(paridad_cmos),

    .DED(DED)

);



//--------------------------------
// LEDs
//
// LED5 = DED
// LED4 = apagado
// LED3-0 = i3 i2 i1 i0 corregidos
//--------------------------------

assign led[5] = ~DED;

assign led[4] = 1'b1;

assign led[3:0] = ~dato_corregido;



//--------------------------------
// Selección del display
//
// btn1 = 0:
// dato recibido
//
// btn1 = 1:
// síndrome
//--------------------------------

always_comb begin


    if(btn1 == 1'b0)

        numero_display = dato_recibido;


    else

        numero_display = {1'b0,sindrome_cmos};


end



//--------------------------------
// Decoder 7 segmentos
//--------------------------------

display7seg DISP(

    .numero(numero_display),

    .display(display)

);



//--------------------------------
// Activación displays
//--------------------------------

assign seg_enable1 = 1'b1;

assign seg_enable2 = 1'b1;


endmodule