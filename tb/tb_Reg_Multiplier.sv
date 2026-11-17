`timescale 1ns / 1ps

module tb_Reg_Multiplier();

    // 1. Declaración de señales internas
    logic [31:0] D;
    logic        clk;
    logic        reset;
    logic        load;
    logic        shift_r;
    logic [31:0] Q;

    // 2. Instanciación del módulo (Unit Under Test)
    Reg_Multiplier uut (
        .D(D),
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift_r(shift_r),
        .Q(Q)
    );

    // 3. Generador de Reloj (Clock) - Cambia cada 5 ns (periodo de 10 ns)
    always #5 clk = ~clk;

    // 4. Estímulos de prueba
    initial begin
        // Inicializar señales
        clk = 1'b0;
        reset = 1'b1;
        load = 1'b0;
        shift_r = 1'b0;
        D = 32'd0;

        // Pulso de Reset
        #15;
        reset = 1'b0;
        #10;

        // Cargar un valor inicial (ejemplo: 32'd5)
        D = 32'd5;
        load = 1'b1;
        #10;

        // Desactivar load y empezar a hacer shifts a la derecha en cada ciclo
        load = 1'b0;
        shift_r = 1'b1;
        #10; // Shift 1
        #10; // Shift 2
        #10; // Shift 3

        // Desactivar shift y terminar
        shift_r = 1'b0;
        #20;
        $finish;
    end

endmodule
