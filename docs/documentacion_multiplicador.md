# Documentación del Proyecto: Multiplicador Secuencial de 32 Bits

- **Curso:** Diseño Digital / Arquitectura de Computadores
- **Herramienta:** SystemVerilog (AMD Vivado)
- **Metodología:** Marco de Trabajo usando IA para Diseño RTL (Proyecto Corto 02)
- **Alcance:** solo el multiplicador secuencial (el divisor lo desarrolla otra parte del equipo)

---

## Etapa 1: Captura de la Intención Humana (Especificación Funcional)

### 1.1 Objetivo del diseño

Implementar en SystemVerilog un multiplicador secuencial **sin signo** de 32 bits basado en el algoritmo de desplazamiento y suma (*Shift-and-Add*) del Capítulo 3 de Patterson & Hennessy. El sistema recibe dos operandos enteros sin signo de 32 bits (multiplicando y multiplicador) y calcula su producto completo de 64 bits de manera iterativa, separando el camino de datos (*datapath*) de la unidad de control.

### 1.2 Comportamiento esperado y algoritmo

1. **Estado de reposo:** el circuito permanece inactivo tras un reinicio hasta que recibe una señal de arranque.
2. **Carga e inicialización:** al recibir la orden de inicio, el sistema captura ambos operandos de 32 bits en sus registros internos (extendiendo el multiplicando a 64 bits con ceros en la parte alta), limpia el acumulador de producto a cero e inicializa el contador de ciclos.
3. **Bucle iterativo (32 repeticiones):** en cada ciclo de reloj durante la ejecución:
   - Se inspecciona el bit menos significativo del multiplicador (`Multiplier[0]`).
   - Si `Multiplier[0] == 1`, se suma el multiplicando al producto y el resultado se almacena de nuevo en el producto.
   - Si `Multiplier[0] == 0`, el producto mantiene su valor.
   - En el mismo ciclo, el multiplicando se desplaza 1 bit a la izquierda y el multiplicador 1 bit a la derecha.
4. **Finalización:** al completarse exactamente 32 iteraciones, el sistema detiene los desplazamientos y escrituras, mantiene el producto de 64 bits estable en la salida y activa una señal de finalización (`ready`).

### 1.3 Cualidades y restricciones de diseño

- **Diseño modular:** cada bloque del diagrama (ALU, registros y contador) es un módulo independiente instanciado en un módulo superior (`main`).
- **Sincronización uniforme:** toda la lógica secuencial opera por flanco positivo de reloj con reinicio asíncrono activo en alto.
- **Reutilización:** la unidad aritmética soporta suma y resta de 64 bits mediante una señal de selección, para ser compatible con otras unidades del proyecto.

---

## Etapa 2: Expansión de la Arquitectura

### 2.1 Jerarquía modular

| Módulo | Naturaleza | Responsabilidad |
|---|---|---|
| `main` | Top-level / control | Integra el datapath y aloja la FSM que gobierna las señales de control. |
| `ALU` | Combinacional | Unidad de 64 bits (`A`, `B`, `Y`) con selector `OP` (`1'b0`: suma A+B, `1'b1`: resta A−B). |
| `Reg_Multiplicand` | Secuencial | Registro de 64 bits con carga paralela (`load`) y desplazamiento a la izquierda (`shift_l`). |
| `Reg_Multiplier` | Secuencial | Registro de 32 bits con carga paralela (`load`), desplazamiento a la derecha (`shift_r`) y salida directa `bit_bajo` (= `Q[0]`). |
| `Reg_Product` | Secuencial | Acumulador de 64 bits con habilitación de escritura síncrona (`write_prod`). |
| `Contador` | Secuencial | Contador ascendente de 6 bits (0 a 31) con `start`, `pause` y bandera `finished` (`Q == 31`). |

### 2.2 Interfaz de puertos del módulo principal (`main`)

| Puerto | Dirección | Ancho | Función |
|---|---|---|---|
| `clk` | input | 1 | Reloj principal (flanco positivo). |
| `reset` | input | 1 | Reinicio asíncrono activo en alto. |
| `start` | input | 1 | Inicio de la operación. |
| `multiplicand_in` | input | 32 | Multiplicando sin signo. |
| `multiplier_in` | input | 32 | Multiplicador sin signo. |
| `product_out` | output | 64 | Resultado de la multiplicación. |
| `ready` | output | 1 | Cálculo concluido (`state == DONE`). |

### 2.3 Máquina de estados finitos (FSM) y señales internas

La unidad de control en `main` tiene 4 estados codificados en 2 bits (`state_t`):

- **`IDLE` (2'b00):** estado inicial tras reset. Espera `start == 1` para pasar a `LOAD`.
- **`LOAD` (2'b01):** activa `load_regs = 1` durante 1 ciclo. Carga `multiplicand_in` (extendido como `{32'd0, multiplicand_in}`) y `multiplier_in`, pone `Reg_Product` en 0 y reinicia `Contador`. Avanza incondicionalmente a `RUN`.
- **`RUN` (2'b10):** activa `shift_en = 1` para desplazar ambos registros e incrementar el contador. Si `bit_bajo == 1`, activa `write_prod = 1` para capturar la salida de la ALU en `Reg_Product`. Permanece hasta que `finished == 1`.
- **`DONE` (2'b11):** activa `ready = 1` y mantiene `product_out` estable. Si recibe un nuevo `start == 1`, regresa a `LOAD` sin necesidad de reset global.

### 2.4 Preguntas aclaratorias y decisiones arquitectónicas

- **¿Se requieren estados separados para sumar y desplazar?** No. La ALU es combinacional y los registros son síncronos al flanco positivo de `clk`, por lo que durante `RUN` la suma Producto + Multiplicando ya está estable antes del flanco. Así se actualiza `Reg_Product` y se desplazan ambos operandos en un único ciclo por bit.
- **¿Cómo accede la unidad de control al bit menos significativo del multiplicador?** `Reg_Multiplier` expone el puerto `bit_bajo`, conectado combinacionalmente a `Q[0]`.

---

## Etapa 3: Revisión Manual Obligatoria (Auditoría de Arquitectura)

Antes de ensamblar el código final se auditó la arquitectura y se corrigieron tres puntos:

1. **Exposición explícita de `Q[0]` en `Reg_Multiplier`.** El primer bosquejo solo tenía el bus `Q[31:0]`. Se agregó la salida `bit_bajo` (`assign bit_bajo = Q[0]`) para tener una interfaz limpia entre datapath y FSM.
2. **Prevención del error off-by-one en las 32 iteraciones.** Se verificó la alineación entre `Contador` y la FSM. Al reiniciar `Contador` durante `LOAD` (`reset || load_regs`), en el primer ciclo de `RUN` vale 0 y en el ciclo 32 vale 31; ahí `finished` se activa y la FSM pasa a `DONE` tras completar la 32.ª evaluación y desplazamiento.
3. **Limpieza del acumulador entre operaciones consecutivas.** La entrada de `Reg_Product` es `load_regs ? 64'd0 : alu_out`, habilitada por `load_regs || write_prod`, de modo que multiplicaciones sucesivas parten siempre de un acumulador en cero.

---

## Etapas 4 y 5: Implementación Incremental y Ensamblaje RTL Auditado

El desarrollo fue incremental, validando cada bloque contra la arquitectura:

1. **Incremento 1 – `rtl/ALU.sv`:** lógica combinacional con `always_comb` y `case(OP)`, con asignación por defecto `'0` para evitar latches.
2. **Incremento 2 – `rtl/Reg_Multiplicand.sv`, `rtl/Reg_Multiplier.sv`, `rtl/Reg_Product.sv`:** lógica secuencial con `always_ff @(posedge clk or posedge reset)`, con prioridad de `load` sobre `shift_l` / `shift_r`.
3. **Incremento 3 – `rtl/Contador.sv`:** contador de 6 bits con habilitación (`start && !pause`) y saturación en 31 (`if (Q < 6'd31)`), para evitar desbordamiento si `start` sigue activo.
4. **Incremento 4 – `rtl/main.sv`:** interconexión de los 5 submódulos y FSM de 4 estados, con la lógica combinacional de salidas (`always_comb`) separada del registro de estado (`always_ff`).

---

## Etapa 6: Verificación Independiente (Bancos de Pruebas)

La verificación tiene dos niveles: pruebas unitarias por submódulo y una prueba de integración con autoverificación en `tb_main.sv`. Todos usan un reloj de 10 ns (`always #5 clk = ~clk`).

### 6.1 Pruebas unitarias

| Testbench | Qué verifica |
|---|---|
| `tb/tb_ALU.sv` | Suma (`10+5`, `1000+500`) y resta (`20-8`, `50-100`). |
| `tb/tb_Reg_Multiplicand.sv` | Reset asíncrono, carga de `64'h5` y 3 desplazamientos a la izquierda (5 → 10 → 20 → 40). |
| `tb/tb_Reg_Multiplier.sv` | Reset, carga de `32'd5` y 3 desplazamientos a la derecha (5 → 2 → 1 → 0). |
| `tb/tb_Reg_Product.sv` | Captura solo con `write_prod == 1` (500 y luego 1200) e ignora el cambio de `D` (999) con `write_prod == 0`. |
| `tb/tb_Contador.sv` | Conteo continuo, congelamiento con `pause = 1` durante 30 ns, reanudación, y `finished` al llegar a `Q = 31`. |

### 6.2 Prueba de integración: `tb/tb_main.sv`

La tarea automática `probar(a, b)` aplica los operandos en `negedge clk`, genera un pulso de 1 ciclo en `start`, espera la transición `ready` 1 → 0 → 1 y compara `product_out` con la referencia `{32'd0, a} * {32'd0, b}`.

| Prueba | `multiplicand_in` | `multiplier_in` | `product_out` esperado | Condición evaluada |
|---|---|---|---|---|
| 1 | `32'd10` | `32'd4` | `64'd40` | Multiplicación básica; multiplicador potencia de 2 (un solo bit en 1). |
| 2 | `32'd15` | `32'd6` | `64'd90` | Varias sumas parciales; operación encadenada sin reset. |
| 3 | `32'd25` | `32'd0` | `64'd0` | Multiplicación por cero (`write_prod` nunca se activa). |
| 4 | `32'd1` | `32'd1` | `64'd1` | Valores mínimos no nulos. |
| 5 | `32'hFFFFFFFF` | `32'hFFFFFFFF` | `64'hFFFFFFFE00000001` (18446744065119617025) | Caso extremo: máximo valor sin signo en ambos operandos. |

---

## Etapa 7: Análisis de Resultados y Trazabilidad

### 7.1 Temporización

- **Latencia determinística:** cada operación tarda 33 ciclos de reloj (330 ns con reloj de 10 ns): 1 ciclo en `LOAD` y 32 en `RUN`, tras lo cual `ready` pasa a nivel alto en `DONE`.
- **Consistencia de señales internas (forma de onda de `tb_main`):** durante `RUN`, cada flanco con `bit_bajo == 1` dispara `write_prod = 1` y actualiza `product_q`, mientras `multiplicand_q` se duplica (`shift_l`) y `multiplier_q` se divide entre dos (`shift_r`).
- **Autoverificación:** las 5 llamadas consecutivas a `probar` deben imprimir el mensaje de confirmación sin disparar `$error`.

> Pendiente: adjuntar aquí las capturas de las formas de onda de Vivado (`docs/img/`).

### 7.2 Matriz de trazabilidad

| Requisito funcional | Elemento de arquitectura | Módulo RTL | Verificación |
|---|---|---|---|
| Operación aritmética de 64 bits | Unidad aritmética combinacional | `ALU.sv` | `tb_ALU.sv`, `tb_main` (prueba 5) |
| Desplazamiento izquierdo del multiplicando | Registro de 64 bits con `shift_l` | `Reg_Multiplicand.sv` | `tb_Reg_Multiplicand.sv`, `tb_main` (prueba 5) |
| Desplazamiento derecho y evaluación del LSB | Registro de 32 bits con `shift_r` y `bit_bajo` | `Reg_Multiplier.sv` | `tb_Reg_Multiplier.sv`, `tb_main` (pruebas 1–5) |
| Acumulación condicional del producto | Registro de 64 bits con `write_prod` | `Reg_Product.sv` | `tb_Reg_Product.sv`, `tb_main` (pruebas 2 y 3) |
| Exactamente 32 iteraciones | Contador de 6 bits (0 a 31) con `finished` | `Contador.sv` | `tb_Contador.sv`, `tb_main` (pruebas 4 y 5) |
| Control secuencial y modularidad | FSM de 4 estados (`IDLE`, `LOAD`, `RUN`, `DONE`) | `main.sv` | `tb_main.sv` (pruebas 1–5 encadenadas) |
