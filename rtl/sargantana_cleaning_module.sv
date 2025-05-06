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


module sargantana_cleaning_module #(
    parameter int unsigned  ICACHE_DEPTH = 64,
    localparam int unsigned ADDR_WIDHT  = $clog2( ICACHE_DEPTH )                                   //- icache Addr vector
)
(
    input  logic                    clk_i           ,
    input  logic                    rstn_i       ,
    input  logic                    flush_enable_i  ,
    output logic                    flush_done_o    ,
    output logic [ADDR_WIDHT-1:0]   addr_q              
);

logic [31:0] depth;
logic [ADDR_WIDHT-1:0] addr_d;

assign depth = ICACHE_DEPTH-1;

assign addr_d       = (flush_enable_i) ? addr_q + 1'b1 : addr_q;
assign flush_done_o = (addr_q==depth[ADDR_WIDHT-1:0]);

always_ff @(posedge clk_i) begin
    if(!rstn_i || flush_done_o ) begin
        addr_q     <= '0;
    end
    else begin
        addr_q     <= addr_d;
    end
end


endmodule
