#!/usr/bin/python

import os

# set sample period/frequency
SP = "1us"
SF = "1MHz"

name = "DS18B20"

# open a TLA700 TXT dump and convert it into a binary dump
txt_dump = open(name+".txt", "r").readlines()
bin_dump = open(name+".bin", "wb")
for line in txt_dump[1:]

bin_dump.(close)

# convert generated binary dump into .sr file
os.system("sigrok-cli -d 0:samplerate="+SF+" -i "+name+".bin"+" -I binary -p 1=OWR -o "+name+".sr")

# TODO, this code should be part of SIGROK
os.system("unzip "+name+".sr")
metadata = open("metadata", "r").readlines()
metadata.insert(6, "samplerate = "+SF+"\n")
open("metadata", "w").writelines(metadata)
os.system("rm -f "+name+".sr")
os.system("zip "+name+".sr"+" version logic-1 metadata")
os.system("rm -f version logic-1 metadata")
