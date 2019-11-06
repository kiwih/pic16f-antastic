# pic16f-antastic
A synthesizable picmicro-midrange clone for FPGAs

Keywords: PIC16F, PIC16F628A, Verilog, SystemVerilog, FPGA, Soft-core

## Description

This is a cycle-accurate FPGA-ready clone of the picmicro-midrange core. 
It was made entirely from the information in the microchip datasheets.
It's mostly written in Verilog, but some small parts (mainly the testbenches) are written in SystemVerilog.
It doesn't yet have very many peripherals (perhaps you could expand the library?) but the core and basic GPIO is ready to go.
You can write programs in MPLAB X (target the 16f628a with MPASM for now) and convert the outputted intel-format hex file to a verilog-ready hex format using the included tool hex2v.

## Getting started

The repository contains these directories:
```
/docs            - contains useful documentation about the pic core
/programs        - a library of programs (all one of them) for running on the core, as well as the hex2v converter tool.
/quartus-de2-115 - a quartus project for running the core on the DE2-115 (or just in the simulator)
/verilog         - the source code of the core, as well as testbenches for automated testing
```

#### Running the core in Modelsim

You can import the Verilog and testbenches to ModelSim however you'd like, 
but my preferred method is to open it in Quartus and then use the `Tools > Run Simulation Tool > RTL Simulation` button
in the menu bar. This launches ModelSim and compiles everything for you automagically, and then you can run one of the 
test scripts in the TCL Command Window.
These scripts are supposed to be run in this order, as each test assumes the previous has already succeeded:
1. `do test_core_basic.tcl` - Runs and verifies basic commands such as AND, ADD, etc.
2. `do test_core_control_flow.tcl` - Runs and verifies the more tricky commands such as GOTO, CALL, RETURN, etc.
3. `do test_core_tmr0.tcl` - Runs and verifies the TMR0 peripheral (TMR0 is a core peripheral so it must be present)
4. `do test_core_isr.tcl` - Enables TMR0 interrupts and verifies that interrupts can occur

#### Running the core on the DE2-115 board

You can actually run the core on any board, but you'll need to make your own project etc. 
My project works on the DE2-115, and connects SWITCHES/LEDG to PORTA, and LCD/LEDR to PORTB.
The default program is "lcd.mem", which is included as the MPLAB project `pic16fantastic_lcd.X`

You can open this and compile and download it, without too much fuss:
![16f-antastic](/docs/picture.jpg)

#### Current 16f-antastic peripherals

To begin with, we're cloning the 16F628A (although not the ADCs or EEPROM of course - no support for those in the FPGA!). 
That said, we don't have any PIN count limitation so I expect I'll break all the peripherals out onto their own pins
instead of MUXing them with PORTA/B.

* Core
- [x] TMR0 
- [x] Watchdog timer 
- [ ] Power control

* External (to core)
- [x] PORTA (fake bidirectional)
- [x] PORTB (true bidirectional)
- [ ] TMR1
- [ ] TMR2
- [ ] CCP
- [ ] USART
