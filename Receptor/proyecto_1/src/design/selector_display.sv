module selector_display(

    input logic btn1,

    input logic [3:0] dato_recibido,

    input logic [2:0] sindrome,


    output logic [3:0] numero_display

);


always_comb begin


    if(btn1 == 1'b0)

        numero_display = dato_recibido;


    else

        numero_display = {1'b0,sindrome};


end


endmodule