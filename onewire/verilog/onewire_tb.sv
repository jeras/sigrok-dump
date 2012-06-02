//////////////////////////////////////////////////////////////////////////////                                                                                          
//                                                                          //
//  1-wire (onewire) testbench                                              //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This RTL is free software: you can redistribute it and/or modify        //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This RTL is distributed in the hope that it will be useful,             //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module onewire_tb;

localparam OWN = 1;    // slaves with different timing (min, typ, max)

//localparam SP = 1us;  // sample period
`ifndef SP
`define SP 1us
`endif

// onewire
wire [OWN-1:0] owr;     // bidirectional

// overdrive enable loop
integer        i;

logic       presence;
logic [7:0] data_w;
logic [7:0] data_r;

int fd;
bit run;
event sample;

//////////////////////////////////////////////////////////////////////////////
// VCD waveforms
//////////////////////////////////////////////////////////////////////////////

// request for a dumpfile
initial begin
  $dumpfile("onewire.vcd");
  $dumpvars(0, onewire_tb);
end

// sampler
initial begin
  fd = $fopen ("onewire.bin", "w");
  run = '1;
  while (run) begin
//    #SP;
    #`SP;
    -> sample;
    $fwrite(fd, "%b", owr);
  end
  $fclose(fd);
end
  
//////////////////////////////////////////////////////////////////////////////
// program
//////////////////////////////////////////////////////////////////////////////

initial begin
  #1ms;
  onewire_master.onewire_reset (presence);
  data_w = 8'h55;
  onewire_master.onewire_byte  (data_w, data_r);
  #1ms;
  run = '0;
  #1;
  $finish();
end

//////////////////////////////////////////////////////////////////////////////
// onewire master/slave models
//////////////////////////////////////////////////////////////////////////////

// pullup
pullup onewire_pullup [OWN-1:0] (owr);

// onewire master
onewire_master #() onewire_master (.owr (owr));

// fast slave device
onewire_slave onewire_slave [OWN-1:0] (.owr (owr));

// typical/fast/slow slave device
//onewire_slave #(.TSN (30    ), .TSO (30)) onewire_slave_n_typ (.owr (owr[0]));
//onewire_slave #(.TSN (15+0.1), .TSO (16)) onewire_slave_n_min (.owr (owr[1]));
//onewire_slave #(.TSN (60-0.1), .TSO (47)) onewire_slave_n_max (.owr (owr[2]));

endmodule
