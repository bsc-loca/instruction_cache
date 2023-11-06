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



module sargantana_icache_checker
    import sargantana_icache_pkg::*;
(
    input  logic                           cmp_enable_q     ,
    input  logic    [ICACHE_TAG_WIDTH-1:0] cline_tag_d      , //- From mmu, paddr.
    input  logic        [ICACHE_N_WAY-1:0] way_valid_bits_i ,
    input  logic                   [ 1:0 ] fetch_idx_i      ,    
    input  logic           [WAY_WIDHT-1:0] ifill_data_i     , //- Cache line. 
    output logic        [ICACHE_N_WAY-1:0] cline_hit_o      ,
    output logic         [FETCH_WIDHT-1:0] data_o           ,
    
    input  logic [ICACHE_N_WAY-1:0][TAG_WIDHT-1:0] read_tags_i,
    input  logic [ICACHE_N_WAY-1:0][WAY_WIDHT-1:0] data_rd_i    //- Cache lines read.

);

logic          [$clog2(ICACHE_N_WAY)-1:0] idx      ;
logic [ICACHE_N_WAY-1:0][FETCH_WIDHT-1:0] cline_sel;
    
genvar i;
generate
for (i=0;i<ICACHE_N_WAY;i++) begin : tag_cmp
    assign cline_hit_o[i]  = (read_tags_i[i] == cline_tag_d) & way_valid_bits_i[i];
    assign cline_sel[i]    = chunk_sel(data_rd_i[i],fetch_idx_i);
end
endgenerate

// find valid cache line
sargantana_icache_tzc_idx tzc_idx (
    .in_i  ( cline_hit_o  ),
    .way_o ( idx          )
);

function automatic logic [FETCH_WIDHT-1:0] chunk_sel(
    input logic [511:0] data,
    input logic [1:0]  offset
  );
    logic [FETCH_WIDHT-1:0] out;
    unique case(offset)
      2'b00:   out = data[(FETCH_WIDHT*1)-1 : FETCH_WIDHT*0];  
      2'b01:   out = data[(FETCH_WIDHT*2)-1 : FETCH_WIDHT*1]; 
      2'b10:   out = data[(FETCH_WIDHT*3)-1 : FETCH_WIDHT*2]; 
      2'b11:   out = data[(FETCH_WIDHT*4)-1 : FETCH_WIDHT*3]; 
      default: out = '0; 
    endcase 
    return out;
endfunction : chunk_sel


assign data_o = cline_sel[idx] ;

                                 
endmodule
