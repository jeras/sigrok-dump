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

// onewire
wire [OWN-1:0] owr;     // bidirectional

// slave conviguration
reg            slave_ena;    // slave enable (connect/disconnect from wire)
reg      [3:0] slave_sel;    // 1-wire slave select
reg            slave_ovd;    // overdrive mode enable
reg            slave_dat_r;  // read  data
wire [OWN-1:0] slave_dat_w;  // write data

// error checking
integer        error;
integer        n;

// overdrive enable loop
integer        i;

//////////////////////////////////////////////////////////////////////////////
// configuration printout and waveforms
//////////////////////////////////////////////////////////////////////////////

// request for a dumpfile
initial begin
  $dumpfile("onewire.vcd");
  $dumpvars(0, onewire_tb);
end

//////////////////////////////////////////////////////////////////////////////
// Avalon write and read transfers
//////////////////////////////////////////////////////////////////////////////

/*
initial begin
  // reset error counter
  error = 0;

  // long delay to skip presence pulse
  slave_ena = 1'b0;
  #1000_000;

  // test with slaves with different timing (each slave one one of the wires)
  for (slave_sel=0; slave_sel<OWN; slave_sel=slave_sel+1) begin

    // select normal/overdrive mode
    //for (slave_ovd=0; slave_ovd<(OVD_E?2:1); slave_ovd=slave_ovd+1) begin
    for (i=0; i<(OVD_E?2:1); i=i+1) begin

      slave_ovd = i[0];

      // generate a reset pulse
      slave_ena   = 1'b0;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b10});
      avalon_polling (8, n);
      // expect no response
      if (data[0] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect responce ('1' expected).", $time);
      end

      // generate a reset pulse
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b10});
      avalon_polling (8, n);
      // expect presence response
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect response ('0' expected).", $time);
      end

      // write '0'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b00});
      avalon_polling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '0'.", $time);
      end
      // check if '0' was read from the slave
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '0'.", $time);
      end

      // write '1', read '1'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b01});
      avalon_polling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '1', read '1'.", $time);
      end
      // check if '1' was read from the slave
      if (data[0] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '1', read '1'.", $time);
      end

      // write '1', read '0'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b0;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b01});
      avalon_polling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '1', read '0'.", $time);
      end
      // check if '0' was read from the slave
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '1', read '0'.", $time);
      end

    end  // slave_ovd

  end  // slave_sel

  // test power supply on a typical normal mode slave
  slave_sel = 0;

  // generate a delay pulse (1ms) with power supply enabled
  avalon_request (16'd1, slave_sel, 3'b011);
  avalon_polling (1, n);
  // check if '1' was read from the slave
  if ((data[0] !== 1'b1) & ~slave_ovd) begin
    error = error+1;
    $display("ERROR: (t=%0t)  Wrong presence detect response (power expected).", $time);
  end
  // check if power is present
  if (owr_p[slave_sel] !== 1'b1) begin
    error = error+1;
    $display("ERROR: (t=%0t)  Wrong line power state", $time);
  end

  // generate a idle pulse (0ms) with power supply enabled
  avalon_request (16'd1, slave_sel, 3'b111);
  avalon_polling (1, n);
  // check if power is present
  if (owr_p[slave_sel] !== 1'b1) begin
    error = error+1;
    $display("ERROR: (t=%0t)  Wrong line power state", $time);
  end

  // generate a delay pulse and break it with an idle pulse, before it finishes
  avalon_request (16'd0, 4'h0, 3'b011);
  avalon_request (16'd0, 4'h0, 3'b111);

  // wait a few cycles and finish
  $finish(); 
end
*/

//////////////////////////////////////////////////////////////////////////////
// onewire master model
//////////////////////////////////////////////////////////////////////////////

onewire_master #() onewire_master (.owr (owr));

// pullup
pullup onewire_pullup [OWN-1:0] (owr);

//////////////////////////////////////////////////////////////////////////////
// onewire slave models
//////////////////////////////////////////////////////////////////////////////

// fast slave device
onewire_slave onewire_slave [OWN-1:0] (.owr (owr));

// typical/fast/slow slave device
//onewire_slave #(.TSN (30    ), .TSO (30)) onewire_slave_n_typ (.owr (owr[0]));
//onewire_slave #(.TSN (15+0.1), .TSO (16)) onewire_slave_n_min (.owr (owr[1]));
//onewire_slave #(.TSN (60-0.1), .TSO (47)) onewire_slave_n_max (.owr (owr[2]));

endmodule
