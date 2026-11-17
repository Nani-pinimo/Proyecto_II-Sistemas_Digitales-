`timescale 1ns / 1ps

module Reg_Multiplier(
    input  logic [31:0] D,
    input  logic        clk,
    input  logic        reset,
    input  logic        load,
    input  logic        shift_r,
    output logic [31:0] Q,
    output logic        bit_bajo  // <--- NUEVO: expone Q[0] para el control
);

    assign bit_bajo = Q[0];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 32'd0;
        end
        else if (load) begin
            Q <= D;
        end
        else if (shift_r) begin
            Q <= {1'b0, Q[31:1]};
        end
    end

endmodule
