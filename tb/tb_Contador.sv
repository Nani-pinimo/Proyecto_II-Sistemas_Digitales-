`timescale 1ns / 1ps

module tb_Contador();

    // 1. Declaración de señales de prueba
    logic       clk;
    logic       reset;
    logic       start;
    logic       pause;
    logic [5:0] Q;
    logic       finished;

    // 2. Instanciación del módulo (Asegúrate de que el nombre coincida con tu módulo)
    Contador uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pause(pause),
        .Q(Q),
        .finished(finished)
    );

    // 3. Generador de Reloj (Periodo de 10 ns -> flanco cada 5ns)
    always #5 clk = ~clk;

    // 4. Estímulos de prueba
    initial begin
        // Inicializar señales
        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        pause = 1'b0;

        // Pulso de Reset inicial
        #15;
        reset = 1'b0;
        #10;

        // Iniciar el conteo
        start = 1'b1;

        // Dejar que cuente un momento libremente
        #60;

        // Probar la pausa por unos ciclos (se congelará un momento)
        pause = 1'b1;
        #30;

        // Quitar la pausa y dejar que termine su recorrido hasta 31
        pause = 1'b0;

        // Tiempo suficiente para que llegue a 31 y se detenga
        #400;

        // Finalizar simulación
        start = 1'b0;
        #20;
        $finish;
    end

endmodule
