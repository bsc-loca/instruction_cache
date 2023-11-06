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


/* Memory used to build a set*/
module sargantana_set_ram
    import sargantana_icache_pkg::*;
(
    input  logic                  clk_i       ,
    input  logic                  rstn_i      ,
    input  logic                  req_i       ,
    //input  logic  [ICACHE_N_SET-1:0] control_i       ,
    input  logic                  we_i        ,
    input  logic  [SET_WIDHT-1:0] data_i      ,
    input  logic [ADDR_WIDHT-1:0] addr_i      ,
    output logic  [SET_WIDHT-1:0] data_o
);

logic [SET_WIDHT-1:0] memory [0:ICACHE_DEPTH-1];

always_ff @(posedge clk_i) begin
    if(!rstn_i) begin
        data_o <= '0;
    end
    else if(req_i) begin
        if(we_i) memory[addr_i] <= data_i;
        else data_o <= memory[addr_i];
    end
end

//genvar i;
//generate
//for ( i=0; i<ICACHE_N_SET; i++ )begin:n_set
//ram ram(
//    .clk_i ( clk_i       ),
//    .rstn_i( rstn_i      ),
//    .req_i ( control_i[i]  ),
//    .we_i  ( we_i        ),
//    .addr_i( addr_i      ),
//    .data_i( data_i      ),   
//    .data_o( data_o [i*SET_WIDHT +: SET_WIDHT ])  //- The acquired data are organized 
//                                                 //  into one vector.
//);
//end
//endgenerate


endmodule

//**************************************************************************
//**************************************************************************


//module ram (
//    input  logic                  clk_i       ,
//    input  logic                  rstn_i      ,
//    input  logic                  req_i       ,
//    input  logic                  we_i        ,
//    input  logic  [SET_WIDHT-1:0] data_i      ,
//    input  logic [ADDR_WIDHT-1:0] addr_i      ,
//    output logic  [SET_WIDHT-1:0] data_o
//);
//
//logic [SET_WIDHT-1:0] memory [0:ICACHE_DEPTH-1];
//
//always_ff @(posedge clk_i) begin
//    if(!rstn_i) begin
//        data_o <= '0;
//    end
//    else if(req_i) begin
//        if(we_i) memory[addr_i] <= data_i;
//        else data_o <= memory[addr_i];
//    end
//end



//endmodule
