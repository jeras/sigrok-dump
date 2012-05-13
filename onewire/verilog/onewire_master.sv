//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  1-wire (onewire) master                                                 //
//                                                                          //
//  Copyright (C) 2012  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This HDL is free software: you can redistribute it and/or modify        //
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
 
`timescale 1us / 1ns

module onewire_master #(
    // optimal timig for master
    parameter T_RSTL = 480.0,  // reset low (min)
    parameter T_RSTH = 480.0,  // reset high (min)
    parameter T_RSTP =  75.0,  // reset presence detect (max)
    parameter T_DAT0 =  60.0,  // data bit 0 (min)
    parameter T_DAT1 =   5.0,  // data bit 1 (min)
    parameter T_DATS =  15.0,  // data sample (max)
    parameter T_REC  =   5.0   // recovery (min)
//  real TS = 30.0   // time slot (min=15.0, typ=30.0, max=60.0)
)(
  inout wire owr  // 1-wire
);

logic pull = '0;

assign owr = pull ? '0 : 'z;

//////////////////////////////////////////////////////////////////////////////
// IO tasks
//////////////////////////////////////////////////////////////////////////////

task onewire_reset (
  output logic presence
); begin
  // low
  pull = '1;
  # T_RSTL;
  // high
  pull = '0;
  # T_RSTP;
  // presence detect
  presence = owr;
  # (T_RSTH-T_RSTP);
end
endtask

task onewire_bit (
  input  bit   data_w,
  output logic data_r
); begin
  // low
  pull = '1;
  # T_DAT1;
  // send 0 or 1
  pull = data_w ? '0 : '1;
  # (T_DATS-T_DAT1);
  // data sample
  data_r = owr;
  // tail
  # (T_DAT0-T_DATS);
  pull = '0;
  // recovery
  # T_REC;
end
endtask

task onewire_byte (
  input  bit   [7:0] data_w,
  output logic [7:0] data_r
);
  int i;
begin
  for (i=0; i<8; i++)  onewire_bit (data_w[i], data_r[i]);
end
endtask

endmodule
