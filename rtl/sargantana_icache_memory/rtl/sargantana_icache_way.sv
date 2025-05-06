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


module sargantana_icache_way 
#(
    parameter int unsigned SET_WIDHT    = 32*8,
    parameter int unsigned ADDR_WIDHT   = 6
)
(
    `ifdef INTEL_PHYSICAL_MEM_CTRL
    input  wire [27:0]            hduspsr_mem_ctrl,
    `endif
    input  logic                  clk_i      ,
    input  logic                  rstn_i     ,
    input  logic                  req_i      ,
    input  logic                  we_i       ,
    input  logic  [SET_WIDHT-1:0] data_i     ,
    input  logic [ADDR_WIDHT-1:0] addr_i     ,
    output logic  [SET_WIDHT-1:0] data_o     
);

    sp_ram #(
        .ADDR_WIDTH(ADDR_WIDHT),
        .DATA_WIDTH(SET_WIDHT),
        `ifdef SRAM_IP
        .INSTANTIATE_ASIC_MEMORY(1'b1),
        `else
        .INSTANTIATE_ASIC_MEMORY(1'b0),
        `endif
        .INIT_MEMORY_ON_RESET('0) // data SRAM doesn't need initialization
    ) sram (
        `ifdef INTEL_PHYSICAL_MEM_CTRL
        .INTEL_MEM_CTRL(hduspsr_mem_ctrl),
        `endif
        .SR_ID('0),
        .clk(clk_i),
        .rst_n(rstn_i),
        .clk_en(req_i),
        .rdw_en(we_i),
        .addr(addr_i),
        .data_in(data_i),
        .data_mask_in({SET_WIDHT{we_i}}),
        .data_out(data_o),
        .srams_rtap_data( /* Unconnected */ ),
        .rtap_srams_bist_command('0),
        .rtap_srams_bist_data('0)
    );

endmodule
