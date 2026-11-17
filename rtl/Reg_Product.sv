`timescale 1ns / 1ps

module Reg_Product(
    input  logic        clk,
    input  logic        reset,
    input  logic        write_prod,
    input  logic [63:0] D,
    output logic [63:0] Q
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 64'd0;
        end
        else if (write_prod) begin
            Q <= D;
        end
    end

endmodule
