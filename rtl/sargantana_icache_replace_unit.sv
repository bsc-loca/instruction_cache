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




//- Logical unit of cache replacement.
//- Valid bit invalidation and replacement strategy

module sargantana_icache_replace_unit 
#(
    parameter int unsigned ICACHE_N_WAY     = 4,
    parameter int unsigned ICACHE_IDX_WIDTH = 6

)
(
    input  logic                            clk_i            ,
    input  logic                            rstn_i           ,
    //input  inval_t                          inval_i          ,
    input  logic                            inval_i          ,
    input  logic                            flush_ena_i      ,
    input  logic                            cache_rd_ena_i   ,
    input  logic                            cache_wr_ena_i   ,
    input  logic         [ICACHE_N_WAY-1:0] way_valid_bits_i ,    
    input  logic                            cmp_en_q         ,
    input  logic     [ICACHE_IDX_WIDTH-1:0] cline_index_i    , //-From core 
    input  logic [$clog2(ICACHE_N_WAY)-1:0] way_to_replace_q ,
    output logic [$clog2(ICACHE_N_WAY)-1:0] way_to_replace_d ,
    //output logic [$clog2(ICACHE_N_WAY)-1:0] way_to_replace_o ,
    output logic                            we_valid_o       ,
    output logic     [ICACHE_IDX_WIDTH-1:0] addr_valid_o     , //Valid address to ram
    output logic         [ICACHE_N_WAY-1:0] data_req_valid_o ,    
    output logic         [ICACHE_N_WAY-1:0] tag_req_valid_o      

);

logic inval_req;
logic lfsr_ena ;
logic all_ways_valid ;

//logic [ICACHE_IDX_WIDTH-1:0] addr_to_inval       ; 
//logic     [ICACHE_N_WAY-1:0] way_to_inval_oh     ;  // way to invalidate (onehot)
logic [$clog2(ICACHE_N_WAY)-1:0] way_to_replace_o ;
logic     [ICACHE_N_WAY-1:0] way_to_replace_q_oh ; // way to replace (onehot)

logic [$clog2(ICACHE_N_WAY)-1:0] a_random_way  ;
logic [$clog2(ICACHE_N_WAY)-1:0] a_invalid_way ;

//--------------------------------------------------------------------------
//----------------------------- Invalidation request from upper cache levels
//  A valid invalidation request
//  flushing takes precedence over invals
//assign inval_req     = ~flush_ena_i & inval_i.valid;
assign inval_req     = ~flush_ena_i & inval_i;
//assign addr_to_inval = inval_i.idx[ICACHE_INDEX_WIDTH-1:ICACHE_OFFSET_WIDTH];

//- Way to invalidate
// translate to Onehot
//always_comb begin
//   way_to_inval_oh = '0;
//   if (inval_req) way_to_inval_oh[inval_i.way] = 1'b1; 
//end

//--------------------------------------------------------------------------
//------------------------------------------------- Invalidation/Replacement
//assign addr_valid_o = (inval_req) ? addr_to_inval : cline_index_i;
assign addr_valid_o = cline_index_i;

//- To tag ram. In an invalidation only clear valid bits. 
                         // A valid read from core.
assign tag_req_valid_o = (cache_rd_ena_i | inval_req) ? '1 : way_to_replace_q_oh;

assign we_valid_o = cache_wr_ena_i | inval_req ;

//- Chose random replacement if all are valid
//- Linear feedback shift register (LFSR)
assign lfsr_ena   = cache_wr_ena_i & all_ways_valid;

assign way_to_replace_o = (all_ways_valid) ? a_random_way : a_invalid_way;
assign way_to_replace_d = (cmp_en_q) ? way_to_replace_o : way_to_replace_q;

// translate to Onehot
always_comb begin
   way_to_replace_q_oh = '0;
   way_to_replace_q_oh[way_to_replace_q] = 1'b1; 
end

// enable signals for idata memory arrays
assign data_req_valid_o   = (cache_rd_ena_i ) ?                  '1 :
                            (cache_wr_ena_i ) ? way_to_replace_q_oh : '0;



// generate random cacheline index
sargantana_icache_lfsr #(
    .ICACHE_N_WAY   ( ICACHE_N_WAY )
) lfsr (
    .clk_i          ( clk_i         ),
    .rst_ni         ( rstn_i        ),
    .en_i           ( lfsr_ena      ),
    .refill_way_o   ( a_random_way  )
);


// find invalid cache line
sargantana_icache_tzc #(
    .ICACHE_N_WAY   ( ICACHE_N_WAY )
) tzc (
    .in_i           ( ~way_valid_bits_i  ),
    .inval_way_o    (  a_invalid_way     ),
    .empty_o        (  all_ways_valid    )
);





endmodule
