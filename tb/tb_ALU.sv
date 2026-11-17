`timescale 1ns / 100ps

module tb_ALU();

    // 1. Declaración de señales internas para conectar a la ALU
    logic [63:0] A;
    logic [63:0] B;
    logic        OP;
    logic [63:0] Y;

    // 2. Instanciación del módulo ALU (Unit Under Test - UUT)
    ALU uut (
        .A(A),
        .B(B),
        .OP(OP),
        .Y(Y)
    );

    // 3. Bloque de estímulos (Pruebas)
    initial begin
        // Inicializar entradas en cero
        A = 64'd0;
        B = 64'd0;
        OP = 1'b0;
        #10; // Esperar 10 ns

        // Pruebas de Suma (OP = 1'b0)
        A = 64'd10;   B = 64'd5;   OP = 1'b0; #10;
        A = 64'd1000; B = 64'd500; OP = 1'b0; #10;

        // Pruebas de Resta (OP = 1'b1)
        A = 64'd20; B = 64'd8;   OP = 1'b1; #10;
        A = 64'd50; B = 64'd100; OP = 1'b1; #10;

        // Fin de la simulación
        #20;
        $finish;
    end

endmodule
