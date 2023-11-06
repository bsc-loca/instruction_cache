/*
 * Copyright 2023 BSC*
 * *Barcelona Supercomputing Center (BSC)
 * 
 * SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 * 
 * Licensed under the Solderpad Hardware License v 2.1 (the “License”); you
 * may not use this file except in compliance with the License, or, at your
 * option, the Apache License version 2.0. You may obtain a copy of the
 * License at
 * 
 * https://solderpad.org/licenses/SHL-2.1/
 * 
 * Unless required by applicable law or agreed to in writing, any work
 * distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */



// A trailing zero counter
module sargantana_icache_tzc_idx
  import sargantana_icache_pkg::*;
(
  input  logic         [ICACHE_N_WAY-1:0] in_i          ,
  output logic [ICACHE_N_WAY_CLOG2-1:0] way_o   
);

// The above solution gives too many warnings, we should opt for a decoder
// THIS ONLY WORKS BECAUSE ICACHE_N_WAY = 4
// If the parameter changes this should change accordingly

always_comb begin
    way_o    = '0;
    if (in_i[0]) way_o = 2'b00;
    else if (in_i[1]) way_o = 2'b01;
    else if (in_i[2]) way_o = 2'b10;
    else if (in_i[3]) way_o = 2'b11;
    else way_o = '0;
end



endmodule 
