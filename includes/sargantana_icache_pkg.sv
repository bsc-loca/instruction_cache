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

package sargantana_icache_pkg;

import drac_pkg::*;

//------------------------------------------------ Global Configuration
//- L1 instruction cache
localparam int unsigned WORD_SIZE    = 64           ; //- Word size in a set.
localparam int unsigned SET_WIDHT    = 512          ; //- Cache line
localparam int unsigned ASSOCIATIVE  = 4            ; //- Number of ways.
localparam int unsigned ICACHE_DEPTH = 64           ; //- .

localparam int unsigned ICACHE_N_WAY = ASSOCIATIVE  ; //- Number of ways.
localparam int unsigned ICACHE_N_WAY_CLOG2 = $clog2( ICACHE_N_WAY );
localparam int unsigned TAG_DEPTH    = ICACHE_DEPTH            ; //- .
localparam int unsigned ADDR_WIDHT   = $clog2( ICACHE_DEPTH )  ; //- icache Addr vector
localparam int unsigned TAG_ADDR_WIDHT = $clog2( TAG_DEPTH )   ; //- 
localparam int unsigned WAY_WIDHT    = SET_WIDHT               ; //- 

`ifdef PADDR_39
localparam int unsigned PADDR_SIZE      = 33;
localparam int unsigned BLOCK_ADDR_SIZE = 33;
localparam int unsigned PPN_BIT_SIZE    = 27;
localparam int unsigned TAG_WIDHT       = 27; //- Tag size.
`else
localparam int unsigned PADDR_SIZE      = 26;
localparam int unsigned BLOCK_ADDR_SIZE = 26;
localparam int unsigned PPN_BIT_SIZE    = 20;
localparam int unsigned TAG_WIDHT       = 20; //- Tag size.
`endif

localparam int unsigned VADDR_SIZE          = drac_pkg::ADDR_SIZE ;
localparam int unsigned ICACHE_INDEX_WIDTH  = 12  ;
localparam int unsigned ICACHE_TAG_WIDTH    = TAG_WIDHT  ;
localparam int unsigned ICACHE_OFFSET_WIDTH = 6   ; // align to 64bytes
localparam int unsigned ICACHE_IDX_WIDTH    = ADDR_WIDHT;

localparam logic [43:0] CachedAddrBeg = 44'h8000_0000; // begin of cached region
localparam logic [43:0] CachedAddrEnd = 44'h80_0000_0000; // end of cached region  

`ifdef FETCH_ONE_INST
    localparam int unsigned FETCH_WIDHT = riscv_pkg::INST_SIZE;
`else
    localparam int unsigned FETCH_WIDHT = drac_pkg::ICACHELINE_SIZE+1; //127+1
`endif

//------------------------------------------------------- exception
typedef struct packed {
    logic [63:0] cause;  // cause of exception
    logic [63:0] tval ;  // additional information of causing exception 
                         // (e.g.: instruction causing it),
                         // address of LD/ST fault
    logic        valid;
} xcpt_t;


//--------------------------------------------------------- iCache

typedef struct packed {
    logic                    valid  ;   // we request a new word
    logic                    kill   ;   // kill the current request
    drac_pkg::icache_idx_t             idx;
    drac_pkg::icache_vpn_t             vpn;  
} ireq_i_t;

typedef struct packed {
    logic                    ready;  // icache is ready
    logic                    valid;  // signals a valid read
    logic [FETCH_WIDHT-1 :0] data ;  // 2+ cycle out: tag
    logic   [VADDR_SIZE-1:0] vaddr;  // virtual address out
    logic                    xcpt ;  // we've encountered an exception
} iresp_o_t;


typedef enum logic[2:0] {NO_REQ, 
                         READ, 
                         MISS, 
                         TLB_MISS, 
                         REPLAY, 
                         KILL,
                         REPLAY_TLB,
                         KILL_TLB
                     } ictrl_state_t;

//------------------------------------------------------
//------------------------------------------------- MMU
    typedef struct packed {    
        logic                  miss ;
        logic                  ptw_v;  // ptw response valid
        logic [PPN_BIT_SIZE-1:0]   ppn  ;  // physical address in
        logic                  xcpt ;  // exception occurred during fetch
    } tresp_i_t;

    typedef struct packed {
        logic                  valid;       // address translation request
        drac_pkg::icache_vpn_t vpn  ;  
    } treq_o_t;


//------------------------------------------------------
//------------------------------------------------- IFILL
  
typedef struct packed {
    logic                            valid  ; //- valid invalidation and
                                              //  invalidate only affected way
    logic                            all    ; //- invalidate all ways
    logic [ICACHE_INDEX_WIDTH-1:0]   idx    ; //- index to invalidate
    logic [$clog2(ICACHE_N_WAY)-1:0] way    ; //- way to invalidate
} inval_t;
  
  typedef struct packed {
      logic         valid ; // Valid response
      logic         ack   ; // IFILL request was received
      logic [511:0] data  ; // Full cache line
      logic   [1:0] beat  ;
  } ifill_resp_i_t;

  typedef struct packed {
      logic                            valid  ;  // valid request
      logic [$clog2(ICACHE_N_WAY)-1:0] way    ;  // way to replace
      logic [PADDR_SIZE-1:0]           paddr  ;  // physical address
  } ifill_req_o_t;




endpackage

