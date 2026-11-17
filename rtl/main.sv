`timescale 1ns / 1ps

module main(
    input  logic        clk,
    input  logic        reset,
    input  logic        start,
    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,
    output logic [63:0] product_out,
    output logic        ready
);

    // 1. Cables de interconexion
    logic [63:0] multiplicand_q;
    logic [31:0] multiplier_q;
    logic [63:0] product_q;
    logic [5:0]  counter_q;
    logic        bit_bajo;
    logic        finished;
    logic [63:0] alu_out;

    // 2. Senales de control
    logic load_regs;
    logic shift_en;
    logic write_prod;

    // 3. Extension del multiplicando a 64 bits
    logic [63:0] ext_multiplicand;
    assign ext_multiplicand = {32'd0, multiplicand_in};

    // 4. ALU: suma
    ALU u_alu (
        .A(product_q),
        .B(multiplicand_q),
        .OP(1'b0),
        .Y(alu_out)
    );

    // 5. Registro del multiplicando
    Reg_Multiplicand u_reg_mcand (
        .D(ext_multiplicand),
        .clk(clk),
        .reset(reset),
        .load(load_regs),
        .shift_l(shift_en),
        .Q(multiplicand_q)
    );

    // 6. Registro del multiplicador
    Reg_Multiplier u_reg_mply (
        .D(multiplier_in),
        .clk(clk),
        .reset(reset),
        .load(load_regs),
        .shift_r(shift_en),
        .Q(multiplier_q),
        .bit_bajo(bit_bajo)
    );

    // 7. Registro del producto
    Reg_Product u_reg_prod (
        .clk(clk),
        .reset(reset),
        .write_prod(load_regs || write_prod),
        .D(load_regs ? 64'd0 : alu_out),
        .Q(product_q)
    );

    // 8. Contador de 32 iteraciones
    Contador u_counter (
        .clk(clk),
        .reset(reset || load_regs),
        .start(shift_en),
        .pause(1'b0),
        .Q(counter_q),
        .finished(finished)
    );

    // 9. Estados de la maquina de control
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        LOAD = 2'b01,
        RUN  = 2'b10,
        DONE = 2'b11
    } state_t;

    state_t state;

    // 10. Control combinacional
    always_comb begin
        // Valores por defecto
        load_regs  = 1'b0;
        shift_en   = 1'b0;
        write_prod = 1'b0;

        case (state)
            IDLE: begin
                // Esperar la senal START
            end

            LOAD: begin
                // Cargar operandos e inicializar producto
                load_regs = 1'b1;
            end

            RUN: begin
                // Evaluar el bit menos significativo
                if (bit_bajo) begin
                    write_prod = 1'b1;
                end
                // Desplazar ambos registros
                shift_en = 1'b1;
            end

            DONE: begin
                // No realizar operaciones
            end

            default: begin
                load_regs  = 1'b0;
                shift_en   = 1'b0;
                write_prod = 1'b0;
            end
        endcase
    end

    // 11. Transiciones de la maquina de estados
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    state <= RUN;
                end

                RUN: begin
                    if (finished) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    if (start) begin
                        state <= LOAD;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // 12. Salidas
    assign product_out = product_q;
    assign ready = (state == DONE);

endmodule
