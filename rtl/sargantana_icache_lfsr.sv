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


// Linear feedback shift register 8bit (LFSR)
module sargantana_icache_lfsr 
#(
    parameter int unsigned ICACHE_N_WAY     = 4
)
(
    input  logic                            clk_i,
    input  logic                            rst_ni,
    input  logic                            en_i,
    output logic [$clog2(ICACHE_N_WAY)-1:0] refill_way_o
);

logic [7:0] shift_d, shift_q;

always_comb begin
    automatic logic shift_in;
    shift_in = !(shift_q[7] ^ shift_q[3] ^ shift_q[2] ^ shift_q[1]);
    shift_d  = shift_q;

    if (en_i) shift_d = {shift_q[6:0], shift_in};
    
    refill_way_o = shift_q[$clog2(ICACHE_N_WAY)-1:0];
end

always_ff @(posedge clk_i or negedge rst_ni) begin : proc_
    if (!rst_ni) shift_q <= '0;
    else         shift_q <= shift_d;
end


endmodule
