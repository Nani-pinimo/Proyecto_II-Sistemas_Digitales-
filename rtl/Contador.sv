`timescale 1ns / 1ps

module Contador(
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic       pause,
    output logic [5:0] Q,
    output logic       finished
);

    assign finished = (Q == 6'd31);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 6'd0;
        end
        else if (start && !pause) begin
            if (Q < 6'd31) begin
                Q <= Q + 1'b1;
            end
        end
    end

endmodule
