`timescale 1ns/1ps


module testbench;


//--------------------------------
// Entradas
//--------------------------------

logic clk;

logic btn1;

logic [7:0] palabra_rx;

logic [2:0] sindrome_cmos;

logic paridad_cmos;



//--------------------------------
// Salidas del TOP
//--------------------------------

wire [5:0] led;

wire [6:0] display;

wire seg_enable1;

wire seg_enable2;



//--------------------------------
// Interpretación real de LEDs
// LEDs físicos activos en bajo
//--------------------------------

wire [3:0] dato_led_real;

wire DED_real;


assign dato_led_real = ~led[3:0];

assign DED_real = ~led[5];



//--------------------------------
// Instancia TOP
//--------------------------------

top DUT(

    .clk(clk),

    .btn1(btn1),

    .palabra_rx(palabra_rx),

    .sindrome_cmos(sindrome_cmos),

    .paridad_cmos(paridad_cmos),

    .led(led),

    .display(display),

    .seg_enable1(seg_enable1),

    .seg_enable2(seg_enable2)

);



//--------------------------------
// Reloj
//--------------------------------

always #5 clk = ~clk;



//--------------------------------
// GTKWave
//--------------------------------

initial begin

    $dumpfile("dump.vcd");

    $dumpvars(0,testbench);

end



//--------------------------------
// Pruebas
//--------------------------------

initial begin


    // Inicialización

    clk = 0;

    btn1 = 0;

    palabra_rx = 8'b00000000;

    sindrome_cmos = 3'b000;

    paridad_cmos = 0;



    #20;



//================================================
// PRUEBA 1
//
// Sin error
//
// Palabra recibida:
// 10100101 = A5
//
// Información:
// 1010
//
// Esperado:
// dato_led_real = 1010
// DED_real = 0
//================================================


    palabra_rx = 8'b10100101;

    sindrome_cmos = 3'b000;

    paridad_cmos = 0;

    btn1 = 0;


    #50;



//================================================
// PRUEBA 2
//
// Error SEC en i3
//
// Recibida:
// 00100101 = 25
//
// Síndrome:
// 111
//
// Corrige a:
// 10100101
//
// Esperado:
// dato_led_real = 1010
// DED_real = 0
//================================================


    palabra_rx = 8'b00100101;

    sindrome_cmos = 3'b111;

    paridad_cmos = 1;

    btn1 = 0;


    #50;



//================================================
// PRUEBA 3
//
// Mostrar síndrome
//
// Síndrome = 011
//
// Esperado:
// Display muestra 3
//================================================


    btn1 = 1;

    sindrome_cmos = 3'b011;


    #50;



//================================================
// PRUEBA 4
//
// DED
//
// Dos errores
//
// Síndrome diferente de cero
// Paridad incorrecta
//
// Esperado:
// DED_real = 1
//================================================


    btn1 = 0;


    palabra_rx = 8'b01100101;

    sindrome_cmos = 3'b001;

    paridad_cmos = 0;


    #50;



//================================================
// PRUEBA 5
//
// Otro dato sin error
//
// Palabra:
// 01011010 = 5A
//
// Información:
// 0101
//
// Esperado:
// dato_led_real = 0101
// DED_real = 0
//================================================


    palabra_rx = 8'b01011010;

    sindrome_cmos = 3'b000;

    paridad_cmos = 0;

    btn1 = 0;


    #50;



//================================================
// PRUEBA 6
//
// Error SEC en i0
//
// Esperado:
// Corrección de dato
// DED_real = 0
//================================================


    palabra_rx = 8'b01011110;

    sindrome_cmos = 3'b011;

    paridad_cmos = 1;

    btn1 = 0;


    #50;



    $finish;


end


endmodule