#!/bin/bash

# cleanup first
rm onewire.out
rm onewire.vcd

# compile and run Verilog projec using "Icarus Verilog"
iverilog -o onewire.out -g2009 onewire_tb.sv onewire_master.sv onewire_slave.sv
vvp onewire.out

# convert generated binary dump into .sr file
sigrok-cli -i onewire.bin -I binary -p 1=OWR -o onewire.sr

# open the waveform in GTKWave and detach it
gtkwave onewire.vcd gtkwave.sav &
