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

`ifdef PITON_SARG
    `include "l15.tmp.h"
`endif

package sargantana_icache_pkg;

import drac_pkg::*;

//------------------------------------------------ Global Configuration

// I$ line size in bits
// NOTE: I$ only supports 32/64-byte cache lines
`ifdef PITON_SARG
    // When using Sargantana with OpenPiton, inherits the size from l15.tmp.h.
    // NOTE: this is the responsibility of sims to enable the ICACHE_32B macro
    // when CONFIG_L1I_CACHELINE_WIDTH equals 256.
    localparam int unsigned ICACHELINE_SIZE = `CONFIG_L1I_CACHELINE_WIDTH;
`elsif ICACHE_32B
    localparam int unsigned ICACHELINE_SIZE = 256;
`else
    localparam int unsigned ICACHELINE_SIZE = 512;
`endif

// I$ total size in KB
`ifdef PITON_SARG
    localparam int unsigned ICACHE_SIZE = `CONFIG_L1I_SIZE/1024;
`else
    localparam int unsigned ICACHE_SIZE = 16;
`endif

// I$ associativity (number of ways)
`ifdef PITON_SARG
    localparam int unsigned ICACHE_ASSOC = `CONFIG_L1I_ASSOCIATIVITY;
`else
    localparam int unsigned ICACHE_ASSOC = 4;
`endif

//------------------------------------------------
localparam int unsigned SET_WIDHT    = ICACHELINE_SIZE ; //- Cache line
localparam int unsigned ICACHE_DEPTH = (((ICACHE_SIZE*1024)/ICACHE_ASSOC)/(ICACHELINE_SIZE/8)) ;

localparam int unsigned ICACHE_N_WAY = ICACHE_ASSOC  ; //- Number of ways.
localparam int unsigned ADDR_WIDHT   = $clog2( ICACHE_DEPTH )  ; //- icache Addr vector
localparam int unsigned WAY_WIDHT    = SET_WIDHT               ; //- 
localparam int unsigned ICACHE_INDEX_SIZE = $clog2(ICACHE_DEPTH) + $clog2(SET_WIDHT/8);

localparam int unsigned ICACHE_PPN_SIZE = drac_pkg::PHY_VIRT_MAX_ADDR_SIZE - ICACHE_INDEX_SIZE;
localparam int unsigned ICACHE_VPN_SIZE = drac_pkg::PHY_VIRT_MAX_ADDR_SIZE - ICACHE_INDEX_SIZE;

`ifdef FETCH_ONE_INST
    localparam int unsigned FETCH_WIDHT = riscv_pkg::INST_SIZE;
`else
    localparam int unsigned FETCH_WIDHT = ICACHELINE_SIZE;
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
typedef logic [ICACHELINE_SIZE-1:0]   icache_line_t;
typedef reg   [ICACHELINE_SIZE-1:0]   icache_line_reg_t;
typedef logic [ICACHE_INDEX_SIZE-1:0] icache_idx_t;
typedef logic [ICACHE_VPN_SIZE-1:0]   icache_vpn_t;

typedef struct packed {
    logic                    valid  ;   // we request a new word
    logic                    kill   ;   // kill the current request
    icache_idx_t             idx;
    icache_vpn_t             vpn;  
} ireq_i_t;

typedef struct packed {
    logic                    ready;  // icache is ready
    logic                    valid;  // signals a valid read
    logic [FETCH_WIDHT-1 :0] data ;  // 2+ cycle out: tag
    logic   [drac_pkg::PHY_VIRT_MAX_ADDR_SIZE-1:0] vaddr;  // virtual address out
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
        logic                       miss  ;
        logic                       ptw_v ;  // ptw response valid
        logic [ICACHE_PPN_SIZE-1:0] ppn   ;  // physical address in
        logic                       xcpt  ;  // exception occurred during fetch
    } tresp_i_t;

    typedef struct packed {
        logic                  valid ;       // address translation request
        icache_vpn_t           vpn   ;
    } treq_o_t;


//------------------------------------------------------
//------------------------------------------------- IFILL
  
typedef struct packed {
    logic                          valid  ; //- valid invalidation and
    logic [ICACHE_INDEX_SIZE-1:0]  paddr  ; //- index to invalidate
} inv_t;
  
  typedef struct packed {
      logic                 valid ; // Valid response
      logic                 ack   ; // IFILL request was received
      logic [SET_WIDHT-1:0] data  ; // Full cache line
      inv_t                 inv   ;
  } ifill_resp_i_t;

  typedef struct packed {
      logic                               valid  ;  // valid request
      logic [drac_pkg::PHY_ADDR_SIZE-1:0] paddr  ;  // physical address
  } ifill_req_o_t;

endpackage

