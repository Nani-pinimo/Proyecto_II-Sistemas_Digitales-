# Proyecto_II-Sistemas_Digitales-

Multiplicador secuencial de 32 bits (algoritmo de desplazamiento y suma, Patterson & Hennessy, cap. 3) en SystemVerilog, desarrollado con el Marco de Trabajo usando IA para diseño RTL (Proyecto Corto 02). Simulado con AMD Vivado.

## Estructura del repositorio

```
.
├── docs/
│   └── documentacion_multiplicador.md   # Documentación de las 7 etapas del marco de trabajo
├── rtl/                                 # Diseño (módulos sintetizables)
│   ├── main.sv                          # Top-level + FSM (IDLE, LOAD, RUN, DONE)
│   ├── ALU.sv                           # Suma / resta de 64 bits
│   ├── Reg_Multiplicand.sv              # Registro de 64 bits, load + shift izquierda
│   ├── Reg_Multiplier.sv                # Registro de 32 bits, load + shift derecha + bit_bajo
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

## Uso en Vivado

1. Agregar los archivos de `rtl/` como *Design Sources* y fijar `main` como módulo superior.
2. Agregar los archivos de `tb/` como *Simulation Sources*.
3. Ejecutar *Run Simulation → Run Behavioral Simulation*. Para la prueba completa, usar `tb_main` como módulo superior de simulación.

## Documentación

Ver [`docs/documentacion_multiplicador.md`](docs/documentacion_multiplicador.md).
