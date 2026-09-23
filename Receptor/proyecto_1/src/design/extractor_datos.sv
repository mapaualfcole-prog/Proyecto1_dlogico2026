module extractor_datos(

    input logic [7:0] palabra_rx,

    output logic [3:0] dato

);


assign dato = {

    palabra_rx[7], // i3
    palabra_rx[6], // i2
    palabra_rx[5], // i1
    palabra_rx[3]  // i0

};


endmodule