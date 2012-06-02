#!/usr/bin/python

import os

# select tool
tool = "iverilog"

# set sample period/frequency
SP = "1us"
SF = "1MHz"

# cleanup first
os.system("rm onewire.out")
os.system("rm onewire.vcd")

# Verilog source files
verilog_sources = "onewire_tb.sv onewire_master.sv onewire_slave.sv"

# Verilog defines
verilog_defines = "-D SP="+SP

# run Verilog simulation
if (tool == "iverilog") :
  # compile and run Verilog projec using "Icarus Verilog"
  os.system("iverilog -o onewire.out -g2009 " + verilog_sources + " " + verilog_defines)
  os.system("vvp onewire.out")

# convert generated binary dump into .sr file
os.system("sigrok-cli -d 0:samplerate="+SF+" -i onewire.bin -I binary -p 1=OWR -o onewire.sr")

# TODO, this code should be part of SIGROK
os.system("unzip onewire.sr")
metadata = open("metadata", "r").readlines()
metadata.insert(6, "samplerate = "+SF+"\n")
open("metadata", "w").writelines(metadata)
os.system("rm -f onewire.sr")
os.system("zip onewire.sr version logic-1 metadata")
os.system("rm -f version logic-1 metadata")

# open the waveform in GTKWave and detach it
#gtkwave onewire.vcd gtkwave.sav &
