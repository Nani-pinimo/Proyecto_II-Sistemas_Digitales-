`timescale 1ns / 1ps

module Reg_Multiplicand(
    input  logic [63:0] D,
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        shift_l,
    output logic [63:0] Q
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 64'd0;
        end
        else if (load) begin
            Q <= D;
        end
        else if (shift_l) begin
            Q <= {Q[62:0], 1'b0};
        end
    end

endmodule
