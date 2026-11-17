`timescale 1ns / 1ps

module tb_Reg_Product();

    // 1. Declaración de señales internas
    logic        clk;
    logic        reset;
    logic        write_prod;
    logic [63:0] D;
    logic [63:0] Q;

    // 2. Instanciación del módulo (Unit Under Test)
    Reg_Product uut (
        .clk(clk),
        .reset(reset),
        .write_prod(write_prod),
        .D(D),
        .Q(Q)
    );

    // 3. Generador de Reloj (Clock) - Cambia cada 5 ns (periodo de 10 ns)
    always #5 clk = ~clk;

    // 4. Estímulos de prueba
    initial begin
        // Inicializar señales
        clk = 1'b0;
        reset = 1'b1;
        write_prod = 1'b0;
        D = 64'd0;

        // Pulso de Reset
        #15;
        reset = 1'b0;
        #10;

        // Simular que la ALU arroja un resultado y ordenamos guardarlo
        D = 64'd500;
        write_prod = 1'b1; // Activamos la escritura
        #10;

        // Desactivar escritura y cambiar D para verificar que retiene el valor anterior
        write_prod = 1'b0;
        D = 64'd999;
        #10;

        // Probar guardar otro valor acumulado
        D = 64'd1200;
        write_prod = 1'b1;
        #10;

        // Finalizar simulación
        write_prod = 1'b0;
        #20;
        $finish;
    end

endmodule
