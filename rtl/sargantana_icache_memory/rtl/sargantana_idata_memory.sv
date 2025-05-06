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



//Build the ways.
module sargantana_idata_memory 
#(
    parameter int unsigned ICACHE_N_WAY = 4,
    parameter int unsigned SET_WIDHT    = 32*8,
    parameter int unsigned ADDR_WIDHT   = 6
)
(
   `ifdef INTEL_PHYSICAL_MEM_CTRL
    input  wire [27:0]                             hduspsr_mem_ctrl,
   `endif
    input  logic                                   clk_i         ,
    input  logic                                   rstn_i        ,
    input  logic                [ICACHE_N_WAY-1:0] req_i         ,
    input  logic                                   we_i          ,
    input  logic                   [SET_WIDHT-1:0] data_i        ,
    input  logic                  [ADDR_WIDHT-1:0] addr_i        ,
    output logic [ICACHE_N_WAY-1:0][SET_WIDHT-1:0] data_way_o      //-One for each way 
);

//The ways are constructed according to the number of ways required.
genvar i;
generate
for ( i=0; i<ICACHE_N_WAY; i++ )begin:n_way
sargantana_icache_way #(
    .SET_WIDHT      ( SET_WIDHT     ),
    .ADDR_WIDHT     ( ADDR_WIDHT    )
) way(
    `ifdef INTEL_PHYSICAL_MEM_CTRL
    .hduspsr_mem_ctrl (hduspsr_mem_ctrl),
    `endif
    .clk_i       ( clk_i          ),
    .rstn_i      ( rstn_i         ),
    .req_i       ( req_i[i]       ),
    .we_i        ( we_i           ),
    .data_i      ( data_i         ),
    .addr_i      ( addr_i         ),
    .data_o      ( data_way_o[i]  )
);
end
endgenerate


endmodule
