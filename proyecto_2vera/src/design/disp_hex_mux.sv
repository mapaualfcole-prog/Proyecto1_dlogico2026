`include "seven_seg_defs.sv"
// Adaptacion del modulo disp_hex_mux.sv provisto por el profesor.
// Contador, MUX 4:1, habilitacion activa en bajo y decodificador conservados.
// CAMBIOS: N=16 para reloj de 27 MHz; A=signo, B=blanco;
// salidas REGISTRADAS y 1 ciclo de apagado al cambiar de digito.
// N=5 se usa EXCLUSIVAMENTE en el testbench (simulacion rapida).
module disp_hex_mux #(parameter integer N = 16) (
    input  logic clk, reset,
    input  logic [3:0] hex3, hex2, hex1, hex0,
    input  logic [3:0] dp_in,
    output logic [3:0] an,      // Activas en BAJO, interfaz del ejemplo
    output logic [7:0] sseg     // Activas en BAJO, interfaz del ejemplo
);
    logic [N-1:0] q_reg, q_next;
    logic [3:0] hex_in;
    logic dp;
    logic [3:0] an_next;
    logic [6:0] seg_next;

    // 16 flip-flops D con reset e incrementador: 27 MHz / 2^16 = 412 Hz.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) q_reg <= '0;
        else       q_reg <= q_next;
    end
    assign q_next = q_reg + 1'b1;

    // MUX 4:1 y decodificador 2:4. Son los 2 MSB del contador.
    always_comb begin
        case (q_reg[N-1:N-2])
            2'b00: begin an_next = 4'b1110; hex_in = hex0; dp = dp_in[0]; end
            2'b01: begin an_next = 4'b1101; hex_in = hex1; dp = dp_in[1]; end
            2'b10: begin an_next = 4'b1011; hex_in = hex2; dp = dp_in[2]; end
            default: begin an_next = 4'b0111; hex_in = hex3; dp = dp_in[3]; end
        endcase
    end

    // Tabla del profesor. A y B reservados SOLO en esta aplicacion.
    always_comb begin
        case (hex_in)
            4'h0: seg_next = `SS_0;
            4'h1: seg_next = `SS_1;
            4'h2: seg_next = `SS_2;
            4'h3: seg_next = `SS_3;
            4'h4: seg_next = `SS_4;
            4'h5: seg_next = `SS_5;
            4'h6: seg_next = `SS_6;
            4'h7: seg_next = `SS_7;
            4'h8: seg_next = `SS_8;
            4'h9: seg_next = `SS_9;
            4'hA: seg_next = 7'b1111110; // Guion: segmento central
            4'hB: seg_next = 7'b1111111; // Blanco: todo apagado
            default: seg_next = 7'b1111111;
        endcase
    end

    // Registrar ambas salidas con UN SOLO reloj.
    // Al comenzar cada nuevo digito apagamos los 4 comunes por 1 ciclo;
    // despues quedan activos sus segmentos y solamente su comun.
    // Evita solapamiento durante la conmutacion (ghosting).
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            an   <= 4'b1111;
            sseg <= 8'hFF;
        end else if (q_reg[N-3:0] == 0) begin
            an   <= 4'b1111;
            sseg <= 8'hFF;
        end else begin
            an   <= an_next;
            sseg <= {dp, seg_next};
        end
    end
endmodule
