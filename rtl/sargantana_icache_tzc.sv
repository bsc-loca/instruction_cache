/*
 * Copyright 2025 BSC*
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
module sargantana_icache_tzc
#(
    parameter int unsigned ICACHE_N_WAY     = 4
)
(
  input  logic         [ICACHE_N_WAY-1:0] in_i          ,
  output logic [$clog2(ICACHE_N_WAY)-1:0] inval_way_o   ,
  output logic                            empty_o         //- Asserted if all bits in 
                                                          // in_i are zero
);

// The above solution gives too many warnings, we should opt for a decoder
// THIS ONLY WORKS BECAUSE ICACHE_N_WAY = 4
// If the parameter changes this should change accordingly

always_comb begin
    inval_way_o    = '0;
    if (in_i[0]) inval_way_o = 2'b00;
    else if (in_i[1]) inval_way_o = 2'b01;
    else if (in_i[2]) inval_way_o = 2'b10;
    else if (in_i[3]) inval_way_o = 2'b11;
    else inval_way_o = '0;
end

assign empty_o = ~(|in_i);

endmodule 
