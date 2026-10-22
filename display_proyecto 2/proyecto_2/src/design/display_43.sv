// Subsistema 4.3: SOLO visualizacion. No calcula A-B.
// Entrada: magnitud ABS(A-B) en binario (0..999) y signo separado.
// cargar es pulso de 1 ciclo, SINCRONIZADO con clk por FSM anterior.
// Salidas: activas en ALTO para 4 digitos CATODO COMUN con NPN low-side.
// NOTA: magnitudes negativas de 4 cifras no caben con signo en 4 displays.
module display_43 #(parameter integer N_REFRESH = 16) (
    input  logic clk,
    input  logic reset,
    input  logic cargar,
    input  logic [9:0] magnitud,
    input  logic negativo,
    output logic [7:0] segmentos_cc,
    output logic [3:0] digitos_cc
);
    logic [9:0] bin_reg;
    logic signo_reg;
    logic pendiente;
    logic [15:0] bcd_rom, bcd_reg;
    logic signo_bcd;
    logic [3:0] hex3, hex2, hex1, hex0;
    logic [3:0] an_bajo;
    logic [7:0] sseg_bajo;

    // Primero se registra la entrada y su signo.
    // Un ciclo despues se registra el valor BCD leido de la ROM.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            bin_reg   <= 10'd0;
            signo_reg <= 1'b0;
            pendiente <= 1'b0;
            bcd_reg   <= 16'h0000;
            signo_bcd <= 1'b0;
        end else begin
            pendiente <= cargar;
            if (cargar) begin
                bin_reg <= magnitud;
                signo_reg <= negativo;
            end
            if (pendiente) begin
                bcd_reg <= bcd_rom;
                signo_bcd <= signo_reg;
            end
        end
    end

    // Se conserva el modulo obligatorio del profesor: ROM 1024 x 16.
    bcd_converter #(.N(10), .M(16)) CONVERSOR (
        .input_bin(bin_reg),
        .output_bcd(bcd_rom)
    );

    // Logica combinacional de formato (sin latches).
    // 4'hA = signo menos, 4'hB = espacio en blanco.
    always_comb begin
        hex0 = bcd_reg[3:0];
        hex1 = bcd_reg[7:4];
        hex2 = bcd_reg[11:8];
        hex3 = bcd_reg[15:12];
        if (bcd_reg[15:12] == 0)
            hex3 = 4'hB;
        if (bcd_reg[15:8] == 0)
            hex2 = 4'hB;
        if (bcd_reg[15:4] == 0)
            hex1 = 4'hB;
        // Rango contractual <=999. El signo cabe en hex3.
        // -0 se representa como 0.
        if (signo_bcd && (bcd_reg != 16'h0000) && (bcd_reg[15:12] == 0))
            hex3 = 4'hA;
    end

    // Multiplexor del profesor adaptado con apagado y salidas registradas.
    disp_hex_mux #(.N(N_REFRESH)) MULTIPLEXOR (
        .clk(clk), .reset(reset),
        .hex3(hex3), .hex2(hex2), .hex1(hex1), .hex0(hex0),
        .dp_in(4'b1111),  // Punto decimal apagado (activo en bajo)
        .an(an_bajo),
        .sseg(sseg_bajo)
    );

    // INTERFAZ ELECTRICA CATODO COMUN:
    // - 1 en segmento = corriente hacia el anodo del LED (con resistencia).
    // - 1 en digito = activa base NPN mediante resistencia; comun a GND.
    assign segmentos_cc = ~sseg_bajo;
    assign digitos_cc   = ~an_bajo;
endmodule
