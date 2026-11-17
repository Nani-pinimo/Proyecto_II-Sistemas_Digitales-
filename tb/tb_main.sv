`timescale 1ns / 1ps

module tb_main();

    logic        clk;
    logic        reset;
    logic        start;
    logic [31:0] multiplicand_in;
    logic [31:0] multiplier_in;
    logic [63:0] product_out;
    logic        ready;

    // Instancia del multiplicador
    main uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .multiplicand_in(multiplicand_in),
        .multiplier_in(multiplier_in),
        .product_out(product_out),
        .ready(ready)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Tarea para probar multiplicaciones
    task automatic probar(
        input logic [31:0] a,
        input logic [31:0] b
    );
        logic [63:0] esperado;
        begin
            // Calcular resultado esperado
            esperado = {32'd0, a} * {32'd0, b};

            // Aplicar operandos y START
            @(negedge clk);
            multiplicand_in = a;
            multiplier_in   = b;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            // Esperar que inicie y termine
            wait(ready == 1'b0);
            wait(ready == 1'b1);

            // Verificar resultado
            if (product_out !== esperado) begin
                $error("ERROR: multiplicacion incorrecta");
            end
            else begin
                $display("Multiplicacion correcta: %0d x %0d = %0d",
                         a, b, product_out);
            end

            #10;
        end
    endtask

    // Estimulos
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        multiplicand_in = 32'd0;
        multiplier_in   = 32'd0;

        // Reset inicial
        #20;
        reset = 1'b0;

        // Prueba 1
        probar(32'd10, 32'd4);

        // Prueba 2
        probar(32'd15, 32'd6);

        // Prueba 3
        probar(32'd25, 32'd0);

        // Prueba 4
        probar(32'd1, 32'd1);

        // Prueba 5
        probar(32'hFFFFFFFF, 32'hFFFFFFFF);

        #20;
        $finish;
    end

endmodule
