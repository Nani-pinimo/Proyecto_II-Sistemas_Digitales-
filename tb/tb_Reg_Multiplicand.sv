`timescale 1ns / 1ps

module tb_Reg_Multiplicand();

    // 1. Declaración de señales internas
    logic [63:0] D;
    logic        clk;
    logic        reset;
    logic        load;
    logic        shift_l;
    logic [63:0] Q;

    // 2. Instanciación del módulo (Unit Under Test)
    Reg_Multiplicand uut (
        .D(D),
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift_l(shift_l),
        .Q(Q)
    );

    // Generador de Reloj (Clock)
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        load = 1'b0;
        shift_l = 1'b0;
        D = 64'd0;

        // Pulso de Reset
        #15;
        reset = 1'b0;
        #10;

        // Cargar un valor inicial (ejemplo: 64'd5, que en binario tiene un '1' y un '1' al inicio)
        D = 64'h0000_0000_0000_0005;
        load = 1'b1;
        #10;

        // Desactivar load y empezar a hacer shifts a la izquierda en cada ciclo
        load = 1'b0;
        shift_l = 1'b1;
        #10; // Shift 1
        #10; // Shift 2
        #10; // Shift 3

        // Desactivar shift y terminar
        shift_l = 1'b0;
        #20;
        $finish;
    end

endmodule
