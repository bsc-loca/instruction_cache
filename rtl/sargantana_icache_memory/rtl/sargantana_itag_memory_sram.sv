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


module sargantana_itag_memory_sram
  import sargantana_icache_pkg::*;
(
    input  logic                                   clk_i      ,
    input  logic                                   rstn_i     ,
    input  logic                [ICACHE_N_WAY-1:0] req_i      ,
    input  logic                                   we_i       ,
    input  logic                                   vbit_i     ,
    input  logic                                   flush_i    ,
    input  logic                   [TAG_WIDHT-1:0] data_i     ,
    input  logic                  [ADDR_WIDHT-3:0] addr_i     ,
    output logic [ICACHE_N_WAY-1:0][TAG_WIDHT-1:0] tag_way_o  , //- one for each way.
    output logic                [ICACHE_N_WAY-1:0] vbit_o       
);

//logic [ICACHE_N_WAY-1:0] mem_ready;

//- To build a memory of tags for each path.

//Valid bit wires
logic [ICACHE_DEPTH-1:0] vbit_vec [0:ICACHE_N_WAY-1];

//--VALID bit vector
genvar i;
generate
for ( i=0; i<ICACHE_N_WAY; i++ )begin
    always_ff @(posedge clk_i) begin
        if(!rstn_i || flush_i) begin
            vbit_vec[i] <= '0; 
            vbit_o[i] <= '0;
        end else if(req_i[i]) begin
            if(we_i) vbit_vec[i][addr_i] <= vbit_i;
            else vbit_o[i] <= vbit_vec[i][addr_i];
        end
    end
end
endgenerate

`ifdef PADDR_39

  //Tag array wires
  logic [107:0] q_sram;
  logic [107:0] write_mask, write_data, w_mask, w_data, mask;
  logic write_enable;
  logic chip_enable;
  logic [ADDR_WIDHT-3:0] address;

  // Tag array SRAM implementation

  assign mask[26:0] = {27{req_i[0]}};
  assign mask[53:27] = {27{req_i[1]}};
  assign mask[80:54] = {27{req_i[2]}};
  assign mask[107:81] = {27{req_i[3]}};
  assign w_mask = {108{we_i}} & mask;
      
  assign w_data[26:0] = data_i;
  assign w_data[53:27] = data_i;
  assign w_data[80:54] = data_i;
  assign w_data[107:81] = data_i;

  assign write_mask = ~w_mask;
  assign write_data = w_data;
  assign write_enable = ~we_i;
  assign address = addr_i;
  assign chip_enable = ~(|req_i);

  `ifdef MEMS_22NM
    `ifdef MEMS_R1PH

      R1PH_64x108 MDArray_tag_il1 (
      .CLK(clk_i),
      .CEN(1'b0), // chip_enable??
      .RDWEN(write_enable),
      .AW(address[5:1]), // Port-A address word line inputs 
      .AC(address[0]), // POrt-A address column inputs 
      .D(write_data), // Data 
      .BW(~write_mask), // Mask 
      .T_LOGIC(1'b0), // Test logic, active high? 
      .MA_SAWL(1'b0), // Margin adjust sense amp. Default: 1'b0
      .MA_WL(1'b0),
      .MA_WRAS(1'b0),
      .MA_WRASD(1'b0),
      .Q(q_sram)
      );
    `else
      R1PD_64x108 MDArray_tag_il1 (
      .CLK(clk_i),
      .CEN(1'b0), // chip_enable??
      .RDWEN(write_enable),
      .AW(address[5:1]), // Port-A address word line inputs 
      .AC(address[0]), // POrt-A address column inputs 
      .D(write_data), // Data 
      .BW(~write_mask), // Mask 
      .T_LOGIC(1'b0), // Test logic, active high? 
      .MA_SAWL(1'b0), // Margin adjust sense amp. Default: 1'b0
      .MA_WL(1'b0),
      .MA_WRAS(1'b0),
      .MA_WRASD(1'b0),
      .Q(q_sram)
      );
    `endif
  `elsif SYNTHESIS_7NM
    RF_SP_64x108 MDArray_tag_il1 (
        .A(address),
        .D(write_data),
        .CLK(clk_i),
        .CEN(1'b0), // chip-enable active-low
        .GWEN(write_enable), // write-enable active-low
        .WEN(write_mask), // write-enable active-low (WEN[0]=LSB)
        .EMA(3'b000),
        .EMAW(2'b00),
        .EMAS(1'b0),
        .Q(q_sram),
        .STOV(1'b0),
        .RET(1'b0)
    );
  `else
  // [47:0]
    TS1N65LPHSA128X48M4F MDArray_tag_A_l1 (
      .A  (address) ,
      .D  (write_data[47:0]) ,
      .BWEB  (write_mask[47:0]) ,
      .WEB  (write_enable) ,
      .CEB  (chip_enable) ,
      .CLK  (clk_i) ,
      .Q  (q_sram[47:0]),
      .WTSEL(3'b000),
      .RTSEL(2'b00),
      .AWT(1'b0)
    ); 
  // [87:48]
    TS1N65LPHSA128X48M4F MDArray_tag_B_l1 (
      .A  (address) ,
      .D  ({16'b0,write_data[79:48]}) ,
      .BWEB  ({16'b1, write_mask[79:48]}) ,
      .WEB  (write_enable) ,
      .CEB  (chip_enable) ,
      .CLK  (clk_i) ,
      .Q  (q_sram[95:48]),
      .WTSEL(3'b000),
      .RTSEL(2'b00),
      .AWT(1'b0)
    ); 
  `endif

  assign tag_way_o[0] = q_sram[26:0];
  assign tag_way_o[1] = q_sram[53:27];
  assign tag_way_o[2] = q_sram[80:54];
  assign tag_way_o[3] = q_sram[107:81];

`else //PADDR_39

  //Tag array wires
  logic [79:0] q_sram;
  logic [79:0] write_mask, write_data, w_mask, w_data, mask;
  logic write_enable;
  logic chip_enable;
  logic [ADDR_WIDHT-3:0] address;


  // Tag array SRAM implementation

  assign mask[19:0] = {20{req_i[0]}};
  assign mask[39:20] = {20{req_i[1]}};
  assign mask[59:40] = {20{req_i[2]}};
  assign mask[79:60] = {20{req_i[3]}};
  assign w_mask = {80{we_i}} & mask;
      
  assign w_data[19:0] = data_i;
  assign w_data[39:20] = data_i;
  assign w_data[59:40] = data_i;
  assign w_data[79:60] = data_i;

  assign write_mask = ~w_mask;
  assign write_data = w_data;
  assign write_enable = ~we_i;
  assign address = addr_i;
  assign chip_enable = ~(|req_i);



  `ifdef MEMS_22NM
    `ifdef MEMS_R1PH
      R1PH_64x80 MDArray_tag_il1 (
      .CLK(clk_i),
      .CEN(1'b0), // chip_enable??
      .RDWEN(write_enable),
      .AW(address[5:1]), // Port-A address word line inputs 
      .AC(address[0]), // POrt-A address column inputs 
      .D(write_data), // Data 
      .BW(~write_mask), // Mask 
      .T_LOGIC(1'b0), // Test logic, active high? 
      .MA_SAWL(1'b0), // Margin adjust sense amp. Default: 1'b0
      .MA_WL(1'b0),
      .MA_WRAS(1'b0),
      .MA_WRASD(1'b0),
      .Q(q_sram)
      );
    `else
      R1DH_64x80 MDArray_tag_il1 (
      .CLK(clk_i),
      .CEN(1'b0), // chip_enable??
      .RDWEN(write_enable),
      .AW(address[5:1]), // Port-A address word line inputs 
      .AC(address[0]), // POrt-A address column inputs 
      .D(write_data), // Data 
      .BW(~write_mask), // Mask 
      .T_LOGIC(1'b0), // Test logic, active high? 
      .MA_SAWL(1'b0), // Margin adjust sense amp. Default: 1'b0
      .MA_WL(1'b0),
      .MA_WRAS(1'b0),
      .MA_WRASD(1'b0),
      .Q(q_sram)
      );
    `endif
  `elsif SYNTHESIS_7NM
    RF_SP_64x80 MDArray_tag_il1 (
        .A(address),
        .D(write_data),
        .CLK(clk_i),
        .CEN(1'b0), // chip-enable active-low
        .GWEN(write_enable), // write-enable active-low
        .WEN(write_mask), // write-enable active-low (WEN[0]=LSB)
        .EMA(3'b000),
        .EMAW(2'b00),
        .EMAS(1'b0),
        .Q(q_sram),
        .STOV(1'b0),
        .RET(1'b0)
    );
  `else
  // [47:0]
    TS1N65LPHSA128X48M4F MDArray_tag_A_l1 (
      .A  (address) ,
      .D  (write_data[47:0]) ,
      .BWEB  (write_mask[47:0]) ,
      .WEB  (write_enable) ,
      .CEB  (chip_enable) ,
      .CLK  (clk_i) ,
      .Q  (q_sram[47:0]),
      .WTSEL(3'b000),
      .RTSEL(2'b00),
      .AWT(1'b0)
    ); 
  // [87:48]
    TS1N65LPHSA128X48M4F MDArray_tag_B_l1 (
      .A  (address) ,
      .D  ({16'b0,write_data[79:48]}) ,
      .BWEB  ({16'b1, write_mask[79:48]}) ,
      .WEB  (write_enable) ,
      .CEB  (chip_enable) ,
      .CLK  (clk_i) ,
      .Q  (q_sram[95:48]),
      .WTSEL(3'b000),
      .RTSEL(2'b00),
      .AWT(1'b0)
    ); 
  `endif

  assign tag_way_o[0] = q_sram[19:0];
  assign tag_way_o[1] = q_sram[39:20];
  assign tag_way_o[2] = q_sram[59:40];
  assign tag_way_o[3] = q_sram[79:60];

`endif //PADDR_39

endmodule
