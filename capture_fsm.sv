// FSM de captura estilo calculadora, con el formato de FSM visto en clase:
// typedef enum, registro de estado (state), logica de siguiente estado (nextstate)
// en always_comb con case, y salidas por assign / always_comb.
// La FSM NO opera datos: solo genera las senales de control para la ruta de datos.
//
//   ENTER_A --(tecla A "-")--> ENTER_B --(tecla B "=")--> SHOW
//   cualquier estado --(tecla C "clear")--> ENTER_A
module capture_fsm (
    input  logic       clk,
    input  logic       rst,
    input  logic       key_valid,
    input  logic [3:0] key_code,
    output logic       clr,          // limpia registros A y B
    output logic       a_digit_en,   // acumula digito en A
    output logic       b_digit_en,   // acumula digito en B
    output logic [1:0] disp_sel      // 00: A, 01: B, 10: resultado
);

    typedef enum logic [1:0] {ENTER_A, ENTER_B, SHOW} state_t;
    state_t state, nextstate;

    // teclas de funcion
    localparam [3:0] KEY_MINUS = 4'hA,
                     KEY_EQ    = 4'hB,
                     KEY_CLR   = 4'hC;

    logic is_digit;
    assign is_digit = (key_code <= 4'd9);

// state register
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= ENTER_A;
        end else begin
            state <= nextstate;
        end
    end

// next state logic and control signals
    always_comb begin
        nextstate  = state;     // por defecto se queda en el mismo estado
        clr        = 1'b0;
        a_digit_en = 1'b0;
        b_digit_en = 1'b0;

        case (state)
            ENTER_A: begin
                if (key_valid) begin
                    if (is_digit) begin
                        a_digit_en = 1'b1;
                    end else if (key_code == KEY_MINUS) begin
                        nextstate = ENTER_B;
                    end else if (key_code == KEY_CLR) begin
                        clr = 1'b1;
                    end
                end
            end
            ENTER_B: begin
                if (key_valid) begin
                    if (is_digit) begin
                        b_digit_en = 1'b1;
                    end else if (key_code == KEY_EQ) begin
                        nextstate = SHOW;
                    end else if (key_code == KEY_CLR) begin
                        clr = 1'b1;
                        nextstate = ENTER_A;
                    end
                end
            end
            SHOW: begin
                if (key_valid && key_code == KEY_CLR) begin
                    clr = 1'b1;
                    nextstate = ENTER_A;
                end
            end
            default: nextstate = ENTER_A;
        endcase
    end

// output logic
    assign disp_sel = (state == ENTER_A) ? 2'b00 :
                      (state == ENTER_B) ? 2'b01 : 2'b10;

endmodule
