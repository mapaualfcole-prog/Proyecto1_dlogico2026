module data_regs (
    input  logic       clk,
    input  logic       reset,
    input  logic       clr,
    input  logic       a_digit_en,
    input  logic       b_digit_en,
    input  logic [3:0] digit,
    output logic [9:0] a_reg,
    output logic [9:0] b_reg
);

    // Cuenta las cifras ingresadas, no el valor del numero.
    logic [1:0] a_count;
    logic [1:0] b_count;

    logic [9:0] digit_ext;
    assign digit_ext = {6'b000000, digit};

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            a_reg   <= 10'd0;
            b_reg   <= 10'd0;
            a_count <= 2'd0;
            b_count <= 2'd0;
        end
        else if (clr) begin
            a_reg   <= 10'd0;
            b_reg   <= 10'd0;
            a_count <= 2'd0;
            b_count <= 2'd0;
        end
        else begin
            if (a_digit_en && a_count < 2'd3) begin
                a_reg <= (a_reg << 3)
                       + (a_reg << 1)
                       + digit_ext;
                a_count <= a_count + 2'd1;
            end

            if (b_digit_en && b_count < 2'd3) begin
                b_reg <= (b_reg << 3)
                       + (b_reg << 1)
                       + digit_ext;
                b_count <= b_count + 2'd1;
            end
        end
    end

endmodule
