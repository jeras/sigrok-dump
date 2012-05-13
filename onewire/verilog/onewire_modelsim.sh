#!/bin/bash

MODELSIM="$HOME/altera/11.1/modelsim_ase/linux"

# cleanup first
rm onewire.out
rm onewire.vcd

# compile and run Verilog projec using "ModelSim"
$MODELSIM/vlib work
$MODELSIM/vlog onewire_tb.sv onewire_master.sv onewire_slave.sv
$MODELSIM/vsim -c -do "run -all" onewire_tb

# convert generated binary dump into .sr file
sigrok-cli -i onewire.bin -I binary -p 1=OWR -o onewire.sr

# open the waveform in GTKWave and detach it
gtkwave onewire.vcd gtkwave.sav &
