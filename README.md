# Proyecto II – Sistemas Digitales

Multiplicador secuencial sin signo de 32 bits, basado en el algoritmo de desplazamiento y suma (*Shift-and-Add*, Patterson & Hennessy, cap. 3), escrito en SystemVerilog. Se desarrolló con el Marco de Trabajo usando IA para diseño RTL (Proyecto Corto 02) y se simuló con AMD Vivado.

> Alcance de este repositorio: el **multiplicador**. El divisor secuencial lo desarrolla otra parte del equipo.

## Contenido

- [Estructura del repositorio](#estructura-del-repositorio)
- [Descripción del diseño](#descripción-del-diseño)
- [Módulos](#módulos)
- [Interfaz del módulo principal](#interfaz-del-módulo-principal)
- [Máquina de estados](#máquina-de-estados)
- [Verificación](#verificación)
- [Cómo simular en Vivado](#cómo-simular-en-vivado)
- [Documentación](#documentación)

## Estructura del repositorio

```
.
├── docs/
│   └── documentacion_multiplicador.md   # Las 7 etapas del marco de trabajo con IA
├── rtl/                                 # Diseño
│   ├── main.sv                          # Top-level + FSM (IDLE, LOAD, RUN, DONE)
│   ├── ALU.sv                           # Suma / resta de 64 bits
│   ├── Reg_Multiplicand.sv              # Registro de 64 bits: load + shift izquierda
│   ├── Reg_Multiplier.sv                # Registro de 32 bits: load + shift derecha + bit_bajo
│   ├── Reg_Product.sv                   # Acumulador de 64 bits
│   └── Contador.sv                      # Contador de 0 a 31 (32 iteraciones)
└── tb/                                  # Bancos de prueba
    ├── tb_main.sv                       # Integración, autoverificado (5 casos)
    ├── tb_ALU.sv
    ├── tb_Reg_Multiplicand.sv
    ├── tb_Reg_Multiplier.sv
    ├── tb_Reg_Product.sv
    └── tb_Contador.sv
```

## Descripción del diseño

El circuito recibe un multiplicando y un multiplicador de 32 bits y entrega el producto completo de 64 bits en 32 iteraciones:

1. En `LOAD` se cargan los operandos (el multiplicando se extiende a 64 bits con ceros), se limpia el producto y se reinicia el contador.
2. En cada ciclo de `RUN`, si el bit menos significativo del multiplicador (`bit_bajo`) vale 1, se suma el multiplicando al producto. En el mismo ciclo, el multiplicando se desplaza 1 bit a la izquierda y el multiplicador 1 bit a la derecha.
3. Al completar las 32 iteraciones, la FSM pasa a `DONE`, mantiene `product_out` estable y activa `ready`.

Cada operación tarda 33 ciclos de reloj: 1 en `LOAD` y 32 en `RUN`.

## Módulos

| Módulo | Tipo | Función |
|---|---|---|
| `main` | Top-level / control | Interconecta el datapath y contiene la FSM. |
| `ALU` | Combinacional | Suma (`OP = 0`) y resta (`OP = 1`) de 64 bits. |
| `Reg_Multiplicand` | Secuencial | 64 bits, carga paralela y desplazamiento a la izquierda. |
| `Reg_Multiplier` | Secuencial | 32 bits, carga paralela, desplazamiento a la derecha y salida `bit_bajo` (`Q[0]`). |
| `Reg_Product` | Secuencial | 64 bits, escritura con habilitación `write_prod`. |
| `Contador` | Secuencial | 6 bits, cuenta de 0 a 31; `finished` se activa en 31. |

Toda la lógica secuencial opera en el flanco positivo de `clk` con reset asíncrono activo en alto.

## Interfaz del módulo principal

| Puerto | Dirección | Ancho | Función |
|---|---|---|---|
| `clk` | input | 1 | Reloj principal. |
| `reset` | input | 1 | Reinicio asíncrono, activo en alto. |
| `start` | input | 1 | Inicia la multiplicación. |
| `multiplicand_in` | input | 32 | Multiplicando sin signo. |
| `multiplier_in` | input | 32 | Multiplicador sin signo. |
| `product_out` | output | 64 | Producto final. |
| `ready` | output | 1 | En 1 cuando el cálculo terminó (`state == DONE`). |

## Máquina de estados

| Estado | Acción |
|---|---|
| `IDLE` | Espera `start`. |
| `LOAD` | `load_regs = 1` durante 1 ciclo; pasa a `RUN`. |
| `RUN` | `shift_en = 1`; `write_prod = 1` si `bit_bajo == 1`; sale cuando `finished == 1`. |
| `DONE` | `ready = 1`; si llega `start`, vuelve a `LOAD` sin necesidad de reset. |

## Verificación

`tb/tb_main.sv` ejecuta cinco multiplicaciones encadenadas y compara cada resultado contra `{32'd0, a} * {32'd0, b}`:

| Prueba | Multiplicando | Multiplicador | Producto esperado |
|---|---|---|---|
| 1 | 10 | 4 | 40 |
| 2 | 15 | 6 | 90 |
| 3 | 25 | 0 | 0 |
| 4 | 1 | 1 | 1 |
| 5 | `FFFFFFFF` | `FFFFFFFF` | `FFFFFFFE00000001` |

Los demás testbenches (`tb_ALU`, `tb_Reg_Multiplicand`, `tb_Reg_Multiplier`, `tb_Reg_Product`, `tb_Contador`) prueban cada submódulo por separado y se revisan en la forma de onda.

## Cómo simular en Vivado

1. Crear un proyecto nuevo y agregar los archivos de `rtl/` como *Design Sources*, con `main` como módulo superior.
2. Agregar los archivos de `tb/` como *Simulation Sources*.
3. Elegir como módulo superior de simulación el testbench que se quiere correr (por ejemplo `tb_main`).
4. Ejecutar *Run Simulation → Run Behavioral Simulation* y revisar la consola y la forma de onda. En `tb_main`, cada prueba correcta imprime `Multiplicacion correcta: ...`.

## Documentación

El detalle de cada etapa del marco de trabajo (especificación, arquitectura, auditoría, implementación, verificación y trazabilidad) está en [`docs/documentacion_multiplicador.md`](docs/documentacion_multiplicador.md).
