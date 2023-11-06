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



module sargantana_tag_way_memory
    import sargantana_icache_pkg::*;
(
    input  logic                  clk_i ,
    input  logic                  rstn_i,
    input  logic                  req_i ,
    input  logic                  we_i  ,
    input  logic                  vbit_i ,
    input  logic                  flush_i ,
    input  logic  [TAG_WIDHT-1:0] data_i,
    input  logic [TAG_ADDR_WIDHT-1:0] addr_i,
    output logic  [TAG_WIDHT-1:0] data_o,
    output logic                  vbit_o
);
    
logic [TAG_WIDHT-1:0] memory [0:TAG_DEPTH-1];

logic [TAG_DEPTH-1:0] vbit_vec;

//--TAG memory
always_ff @(posedge clk_i) begin
    if(!rstn_i)
        data_o <= '0; 
    else if(req_i) begin
        if(we_i) memory[addr_i] <= {data_i};
        else data_o <= memory[addr_i];
    end
end

//--VALID bit vector

always_ff @(posedge clk_i) begin
    if(!rstn_i || flush_i) vbit_vec <= '0; 
    else if(req_i) begin
        if(we_i) vbit_vec[addr_i] <= vbit_i;
        else vbit_o <= vbit_vec[addr_i];
    end
end





//assign data_o = data_aux[TAG_WIDHT-1:0];
//assign vbit_o = data_aux[TAG_WIDHT];

endmodule

