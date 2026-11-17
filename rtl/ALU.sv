`timescale 1ns / 1ps

module ALU(
    input  logic [63:0] A,
    input  logic [63:0] B,
    input  logic        OP,
    output logic [63:0] Y
);

    always_comb begin
        case(OP)
            1'b0:    Y = A + B;  // Suma
            1'b1:    Y = A - B;  // Resta (por si se usa en Booth o extensión, por defecto suma)
            default: Y = '0;
        endcase
    end

endmodule
