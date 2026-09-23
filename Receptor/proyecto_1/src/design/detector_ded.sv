module detector_ded(

    input logic [2:0] sindrome,

    input logic paridad_recibida,

    input logic paridad_cmos,

    output logic DED

);


always_comb begin


    if((sindrome != 3'b000) &&
       (paridad_cmos == 1'b0))


        DED = 1'b1;


    else


        DED = 1'b0;


end


endmodule