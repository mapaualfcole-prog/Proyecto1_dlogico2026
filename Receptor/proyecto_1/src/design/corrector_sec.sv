module corrector_sec(

    input logic [6:0] palabra,

    input logic [2:0] sindrome,

    output logic [6:0] corregida

);


always_comb begin


    corregida = palabra;


    case(sindrome)


        3'b001:
            corregida[0] = ~palabra[0];


        3'b010:
            corregida[1] = ~palabra[1];


        3'b011:
            corregida[2] = ~palabra[2];


        3'b100:
            corregida[3] = ~palabra[3];


        3'b101:
            corregida[4] = ~palabra[4];


        3'b110:
            corregida[5] = ~palabra[5];


        3'b111:
            corregida[6] = ~palabra[6];


        default:
            corregida = palabra;


    endcase


end


endmodule