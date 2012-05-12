#!/bin/bash

# cleanup first
rm onewire.out
rm onewire.vcd

# compile and un Verilog projec using "Icarus Verilog"
iverilog -o onewire.out -g2009 onewire_tb.sv onewire_master.sv onewire_slave.sv
vvp onewire.out

# open the waveform in GTKWave and detach it
gtkwave onewire.vcd gtkwave.sav &
